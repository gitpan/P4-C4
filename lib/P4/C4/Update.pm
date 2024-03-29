# $Revision: 709 $$Date: 2005-05-03 17:32:07 -0400 (Tue, 03 May 2005) $$Author: wsnyder $
# Author: Wilson Snyder <wsnyder@wsnyder.org>
######################################################################
#
# Copyright 2002-2005 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
######################################################################

package P4::C4::Update;
use strict;

our $VERSION = '2.041';

######################################################################
######################################################################
######################################################################
#### Package overrides

package P4::C4;
use P4::C4::Info;
use P4::C4::Cache;
use P4::C4::Ignore;
use P4::C4::Diff;
use P4::C4::Sync;
use Data::Dumper;
use strict;

sub update {
    my $self = shift;
    my @params = @_;

    $self->clientRoot or die "%Error: Not inside a client spec, cd to inside one.\n";
    # Not yet:
    #$self->clientC4Managed or die "%Error: Client was not created by c4 client-create\n";

    my $add;
    my $delete;
    my $printIgnored;
    my @files;
    foreach my $param (@params) {
	if ($param eq "-n") {
	    $self->{opt}->noop(1);
	} elsif ($param eq "-rl") {
	    $delete = 1;
	} elsif  ($param eq '-a') {
	    $add = 1;
	} elsif ($param eq "-pi") {
	    $printIgnored = 1;
	} elsif ($param =~ /^-/) {
	    die "%Error: Unknown update parameter: $param\n";
	} else {
	    push @files, P4::C4::Path::fileDePerforce($param);
	}
    }

    push @files, $self->clientRoot if $#files<0;

    # Grab status
    $self->readCache();
    foreach my $file (@files) {
	$self->findFiles($file);
	$self->fstatFiles($file);
    }

    #use Data::Dumper; print Dumper($self->{_files});
    # Update files
    my $unresolvedAny;
    foreach my $fref (sort {$a->{filename} cmp $b->{filename}}
		      (values %{$self->{_files}})) {
	# If the user edited a file, the mtime has changed.
	# We need to either p4 edit, p4 revert, or leave it as is if it's edited.
	my $unresolvedThis = defined $fref->{unresolved};
	if ($unresolvedThis) {
	    #use Data::Dumper; print Dumper($fref) if $P4::C4::Debug;
	}
	if (($fref->{action}||"") eq 'add') {
	    if (!$fref->{depotExists}) {
		$fref->{status} = 'A-    ';
	    } else {
		$fref->{status} = 'A-adad';  # Add add conflict?
	    }
	}
	elsif (($fref->{action}||"") eq 'delete') {
	    if ($fref->{depotExists}) {
		$fref->{status} = 'R-    ';
	    } else {
		$fref->{status} = 'R-dede'; # delete/delete conflict?
	    }
	}
	elsif ($fref->{depotExists} && !$fref->{clientMtime}) {
	    # Exists, but user doesn't have it
	    if ($fref->{haveRev}) {
		$fref->{status} = 'l-lost';
		# If delete then delete the file from perforce
		if ($delete) {
			$fref->{status} = 'R-rlop';
			if (!$self->{opt}->noop) {
			    my $ui = new P4::C4::UI();
			    $self->Delete($ui, $fref->{filename});
			}
		} elsif (($fref->{action}||'') eq 'edit') {
		    $self->_updateAction($fref,"revert",$fref->{filename});
		} else {
		    $self->_updateAction($fref,"sync","-f",$fref->{filename});
		}
	    } else {
		$fref->{status} = 'a-new ';
		# Else the sync below should get it.  (Probably a new file, never updated.)
	    }
	}
	elsif (($fref->{action}||'') eq 'edit'
	       || ($fref->{action}||'') eq 'branch') {
	    if (($fref->{oldMtime}||0) == ($fref->{clientMtime}||1)) {
		$fref->{differs} = 1;	# No change again, still appropriate in edit
	    } else {
		_updateDiffers($self,$fref);
	    }
	    if ($fref->{differs}) {
		if ($unresolvedThis) {
		    $fref->{status} = 'C-same';
		} else {
		    $fref->{status} = 'M-same';
		}
	    } else {
		# Was edited, can revert it
		$fref->{status} = 'm-revt';
		$self->_updateAction($fref,"revert",$fref->{filename});
		$unresolvedThis = 0;
	    }
	}
	elsif ($fref->{depotExists} && $fref->{clientMtime}) {
	    # Exists and user has it
	    if (($fref->{oldMtime}||0) == ($fref->{clientMtime}||1)) {
		$fref->{differs} = 0;	# No change again, still not edited
	    } else {
		_updateDiffers($self,$fref);
	    }
	    if ($fref->{differs}) {
		# Need to p4 edit it.
		$fref->{status} = 'M-edit';
		$self->_updateAction($fref,"edit",$fref->{filename});
	    }
	    else {
		# No edit needed, unmodified
	    }
	}
	elsif (($fref->{headAction}||"") eq "delete"
	       && $fref->{clientMtime}) {
	    $fref->{status} = 'd-upde';	# Update will delete it.
	}
	$unresolvedAny ||= $unresolvedThis;
    }

    # Now sync.
    if ($self->{opt}->noop) {
	$self->syncFiles('-n', @files);
    } else {
	$self->syncFiles(@files);
    }

    # Print stats
    $self->ignoredFiles();
    foreach my $fref (sort {$a->{filename} cmp $b->{filename}}
		      (values %{$self->{_files}})) {
	my $stat = $fref->{status};  # May be defined or not
	if ($fref->{unknown}) {
	    if ($add && !$fref->{status}) {
		$fref->{status} = 'A-aopt';
		$stat = 'A-aopt';
		if (!$self->{opt}->noop) {
		    my $ui = new P4::C4::UI();
		    $self->Add($ui, $fref->{filename});
		}
	    }
	    $stat ||= '?-    ';
	}

	if ($printIgnored) {
	    $stat ||= 'i-    ' if ($fref->{ignore});
	}
	if ($stat) {
	    $stat =~ s/-.*$// if !$P4::C4::Debug;
	    print $stat." ".$fref->{filename}."\n";
	}
    }

    if ($unresolvedAny) {
	print "-Info: Conflicts found.  Run 'c4 resolve'\n";
    }

    # Save output
    $self->writeCache() if !$self->{opt}->noop;
}

sub _updateDiffers {
    my $self = shift;
    my $fref = shift;
    # Compare against what we HAVE, else someone else's change will be a diff
    if ($fref->{haveRev}) {
	$fref->{differs} = $self->differentFiles('-f',$fref->{filename}."#".$fref->{haveRev});
    } else {
	$fref->{differs} = 0;
    }
}

sub _updateAction {
    my $self = shift;
    my $fref = shift;
    my @params = @_;
    print "_updateAction(@params $fref->{filename})\n" if $P4::C4::Debug;
    if (!$self->{opt}->noop) {
	my $ui = new P4::C4::UI();
	$self->Run($ui,@params);
    }
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::File - Information on one C4 tracked file

=head1 SYNOPSIS

  use P4::C4::Diff;

  my $p4 = new P4::C4;
  $p4->update (<params>)
  ...

=head1 DESCRIPTION

This module implements the C4 update command.

=head1 DISTRIBUTION

The latest version is available from CPAN and from L<http://www.veripool.com/>.

Copyright 2002-2005 by Wilson Snyder.  This package is free software; you
can redistribute it and/or modify it under the terms of either the GNU
Lesser General Public License or the Perl Artistic License.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=head1 SEE ALSO

L<P4::C4>

=cut
