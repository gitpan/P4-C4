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

package P4::C4::Unknown;
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

sub unknown {
    my $self = shift;
    my @params = @_;

    $self->clientRoot or die "%Error: Not inside a client spec, cd to inside one.\n";

    my @files;
    my $add;
    my $printIgnored;
    foreach my $param (@params) {
	if ($param eq '-a') {
	    $add = 1;
	} elsif ($param eq "-pi") {
	    $printIgnored = 1;
	} elsif ($param =~ /^-/) {
	    die "%Error: Unrecognized 'c4 unknown' parameter: $param\n";
	} else {
	    push @files, P4::C4::Path::fileDePerforce($param);
	}
    }

    push @files, $self->clientRoot if $#files<0;

    # Grab status
    foreach my $file (@files) {
	$self->findFiles($file);
	$self->fstatFiles($file);
    }

    # Print stats
    $self->ignoredFiles();
    foreach my $fref (sort {$a->{filename} cmp $b->{filename}}
		      (values %{$self->{_files}})) {
	next if $fref->{action};
	my $stat = $fref->{status};  # May be defined or not
	if ($fref->{unknown}) {
	    if ($add) {
		$stat ||= 'a-    ';
		my $ui = new P4::C4::UI();
		$self->Add($ui, $fref->{filename});
	    } else {
		$stat ||= '?-    ';
	    }
	}
	if ($printIgnored) {
	    $stat ||= 'i-    ' if ($fref->{ignore});
	}
	if ($stat) {
	    $stat =~ s/-.*$// if !$P4::C4::Debug;
	    print $stat." ".$fref->{filename}."\n";
	}
    }
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::Unknown - Print unknown files

=head1 DESCRIPTION

This module implements the C4 unknown command.

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
