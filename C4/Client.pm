# $Revision: 1.17 $$Date: 2004/01/27 18:59:22 $$Author: wsnyder $
# Author: Wilson Snyder <wsnyder@wsnyder.org>
######################################################################
#
# Copyright 2002-2004 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
######################################################################

package P4::C4::Client;
require 5.006_001;

use strict;
use vars qw($VERSION);
use Carp;

use P4::Getopt;
use P4::C4::Cache;
use P4::C4::Info;

######################################################################
#### Configuration Section

$VERSION = '2.021';

#######################################################################
#######################################################################
#######################################################################
# Client Interface

package P4::C4::Client::CreateUI;
use P4::C4::UI;
use strict;
our @ISA = qw( P4::C4::UI );

sub Edit {
    my $self = shift;
    my $filename = shift;
    print __FUNCTION__.": $filename\n" if $P4::C4::Debug;

    # Replace the appropriate fields in the template
    # Read it
    my $ifh = IO::File->new($filename) or die "%Error: $! $filename,";
    my $wholefile = join('',$ifh->getlines);
    $ifh->close();

    # Edits
    my $out = "";
    my $des;
    foreach my $line (split /\n/, $wholefile) {
	$line =~ s/\b(Host:\t)\S+/$1/mg;
	$line =~ s/\bnoallwrite\b/allwrite/mg if $self->{c4} || $self->{allwrite};
	$line =~ s/\bnoclobber\b/clobber/mg if $self->{c4} || $self->{clobber};
	$line =~ s/\bnormdir\b/rmdir/mg if $self->{rmdir};
	if ($line =~ /^Description:/) {
	    $des=1;
	}
	elsif ($des && $line =~ /^[a-z\#]/i) {
	    $des=0;
	    $out .= "\tManaged by c4.\n\n" if $self->{c4};
	}
	$out .= "$line\n";
    }

    # Write it back
    my $fh = IO::File->new($filename,"w") or die "%Error: $! $filename,";
    print $fh $out;
    $fh->close();

    # Now let the user do their thing.
    P4::UI->Edit($filename);
}

#######################################################################
# Client Interface

package P4::C4::Client::DeleteUI;
use P4::C4::UI;
use strict;
our @ISA = qw( P4::C4::UI );

sub Edit {
    my $self = shift;
    my $filename = shift;
    print __FUNCTION__.": $filename\n" if $P4::C4::Debug;

    # Read it
    my $ifh = IO::File->new($filename) or die "%Error: $! $filename,";
    my $wholefile = join('',$ifh->getlines);
    $ifh->close();

    # Edits
    my $out = "";
    my $view;
    foreach my $line (split /\n/, $wholefile) {
	if ($line =~ /^View:/) {
	    $view=1;
	} elsif ($line =~ /^[a-z\#]/i) {
	    $view=0;
	} elsif ($view) {
	    next;
	}
	$out .= "$line\n";
    }

    # Write it back
    my $fh = IO::File->new($filename,"w") or die "%Error: $! $filename,";
    print $fh $out;
    $fh->close();
}

#######################################################################
#######################################################################
#######################################################################
# Client View Interface

package P4::C4::Client::ViewUI;
use P4::C4::UI;
use strict;
our @ISA = qw( P4::C4::UI );

sub OutputInfo {
    my $self = shift;
    my $level = shift;
    my $data = shift;

    if ($level==0) {
	my $inview;
	print __PACKAGE__.": $level: $data\n" if $P4::C4::Debug;
	foreach my $line (split /\n/, $data) {
	    if ($line =~ /^View:/) {
		$inview = 1;
	    } elsif ($inview && $line =~ /^\s+(\S+)\s+(\S+)/) {
		push @{$self->{view}}, [$1, $2];
	    } elsif ($line =~ /Managed by c4/) {
		$self->{c4_managed} = 1;
	    } else {
		$inview = 0;
	    }
	}
    } else {
	die "$0: %Error: Bad p4 response: $data\n";
    }
}

#######################################################################
#######################################################################
#######################################################################
# OVERRIDE METHODS

package P4::C4;
use File::Path;
use Cwd;

sub createClient {
    my $self = shift;
    my @args = @_;  # allwrite, clobber, rmdir, c4
    # Create the client
    print "createClient ",join(' ',@args),"\n" if $P4::C4::Debug;

    (! -r ".p4config") or die "%Error: Client already exists (.p4config file exists)\n";

    # Set client name
    my %opts = P4::Getopt->hashCmd('client-create', @args);
    #use Data::Dumper; print Dumper(\%opts) if $P4::C4::Debug;
    (!$opts{unknown}) or die "%Error: Unknown create-client switch\n";
    $opts{client}[0] or die "%Error: New client name not specified\n";
    $self->SetClient($opts{client}[0]) if $opts{client}[0];

    # Call perforce to make the client
    my @p4args;
    foreach my $opt (@args) {
	push @p4args, $opt if $opt ne "-c4" && $opt ne "-rmdir";
    }

    my $ui = new P4::C4::Client::CreateUI ('c4' => $opts{-c4},
					   'rmdir' => $opts{-rmdir},);
    $self->Run($ui,'client',@p4args);

    # Check the user didn't modify the description
    if ($opts{-c4} && !$self->clientC4Managed) {
	warn "%Error: The Description: ... 'Managed by c4.' shouldn't be deleted\n"
	    ."        Please use 'c4 client' and add it back.\n";
    }

    # Write .p4config file
    my $cfgfilename = $ENV{P4CONFIG} or die "%Error: P4CONFIG not in enviornment,";
    my $fh = IO::File->new($cfgfilename,"w",0777) or die "%Error: $! %cfgfilename,";
    chmod 0777, $cfgfilename;
    printf $fh "P4CLIENT=".$self->GetClient()."\n";
    my $user = ($ENV{P4USER}||$ENV{USER});
    printf $fh "P4USER=$user\n" if $user;
    printf $fh "#C4\n";	   # Magic sequence so know under our control
    $fh->close();

    unlink('.c4cache');
    $self->rmCache();

    return 1;
}

#######################################################################

sub clientDelete {
    my $self = shift;
    my @args = @_;

    print "clientDelete ",join(' ',@args),"\n" if $P4::C4::Debug;

    # Set client name
    my %opts = P4::Getopt->hashCmd('client-delete', @args);
    (!$opts{unknown}) or die "%Error: Unknown create-delete switch\n";
    $opts{client}[0] or die "%Error: Deletion client name not specified\n";
    $self->SetClient($opts{client}[0]) if $opts{client}[0];

    # Check if it exists
    my $root = $self->clientRoot;
    defined $root or die "%Error: Client '$opts{client}[0]' doesn\'t exist.\n";
    print "Root $root\n" if $P4::C4::Debug;
    my $madedir;
    if (-r $root) {
	print "Deleting client $opts{client}[0] and client directory $root...\n";
    } else {
	print "Deleting client $opts{client}[0] and empty client directory $root...\n";
	$madedir = 1;
	mkpath $root;
	(-r $root) or die "%Error: Can't create directory: $root\n";
    }

    # Chdir
    my $orig_pwd = getcwd();
    chdir($root);
    $self->SetCwd($root);

    my $ui = new P4::C4::UI(c4self=>$self, noneOpenOk=>1);

    # Revert any open files
    $self->Run($ui,'revert','...');

    {   # Edit the view to remove old areas
	my $eui = new P4::C4::Client::DeleteUI(c4self=>$self);
	$self->Run($eui,'client');
    }

    # Sync to remove the old view files
    $self->Run($ui,'sync','-f');

    {   # Call perforce to delete the client
	my @delargs = ();  
	push @delargs, '-f' if $opts{-f};
	$self->Run($ui,'client','-d', @delargs, $opts{client}[0]);
    }

    # Delete created files
    unlink("$root/.c4cache");
    unlink("$root/.p4config");
    rmdir $root if $madedir;

    chdir $orig_pwd;
    $self->SetCwd($orig_pwd);

    return 1;
}

######################################################################

sub clientDetails {
    my $self = shift;
    my @args = @_;
    # Return view fields from current client

    $self->{view} = [];

    my $ui = new P4::C4::Client::ViewUI (c4self=>$self);
    $self->Run($ui,'client','-o');

    return ($ui);
}

sub clientView {
    my $self = shift;
    my $ui = $self->clientDetails(@_);
    return (@{$ui->{view}});
}

sub clientC4Managed {
    my $self = shift;
    if (!defined $self->{c4_managed}) {
	my $ui = $self->clientDetails(@_);
	$self->{c4_managed} = $ui->{c4_managed} ? 1:0; 
    }
    return $self->{c4_managed}; 
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::Client - Client utilities

=head1 SYNOPSIS

  use P4::C4::Client;

  my $p4 = new P4::Client;
  $p4->createClient( \@args );
  ...

=head1 DESCRIPTION

This module provides utilities to operate on Perforce clients.

=head1 METHODS

=over 4

=item $self->createClient ( args )

Create the client in a way supported by c4.  With the '-c4' parameter, set
clobber, allwrite.  With '-rmdir', set rmdir.  You'll probably also want
the -t template argument.

=item $self->clientView ( args )

Return an array with the view of the current client.

=back

=head1 SEE ALSO

C<P4::Client>, C<P4::C4>, 

=head1 DISTRIBUTION

The latest version is available from CPAN.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut
