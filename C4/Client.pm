# $Revision: 1.6 $$Date: 2002/07/25 18:17:15 $$Author: wsnyder $
# Author: Wilson Snyder <wsnyder@wsnyder.org>
######################################################################
#
# This program is Copyright 2002 by Wilson Snyder.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of either the GNU General Public License or the
# Perl Artistic License.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# If you do not have a copy of the GNU General Public License write to
# the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, 
# MA 02139, USA.
######################################################################

package P4::C4::Client;
require 5.6.0;

use strict;
use vars qw($VERSION);
use Carp;

use P4::Getopt;
use P4::C4::Cache;

######################################################################
#### Configuration Section

$VERSION = '2.000';

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
    my $wholefile = <$ifh>;
    { local $/; undef $/; $wholefile = <$ifh>; }
    $ifh->close();

    # Edits
    $wholefile =~ s/\b(Host:\t)\S+/$1/mg;
    $wholefile =~ s/\bnoallwrite\b/allwrite/mg if $self->{c4} || $self->{allwrite};
    $wholefile =~ s/\bnoclobber\b/clobber/mg if $self->{c4} || $self->{clobber};
    $wholefile =~ s/\bnormdir\b/rmdir/mg if $self->{rmdir};

    # Write it back
    my $fh = IO::File->new($filename,"w") or die "%Error: $! $filename,";
    print $fh $wholefile;
    $fh->close();

    # Now let the user do their thing.
    P4::UI->Edit($filename);
}

#######################################################################
#######################################################################
#######################################################################
# OVERRIDE METHODS

package P4::C4;
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

    # Write .p4config file
    my $cfgfilename = $ENV{P4CONFIG} or die "%Error: P4CONFIG not in enviornment,";
    my $fh = IO::File->new($cfgfilename,"w",0777) or die "%Error: $! %cfgfilename,";
    chmod 0777, $cfgfilename;
    printf $fh "P4CLIENT=".$self->GetClient()."\n";
    printf $fh "#C4\n";	   # Magic sequence so know under our control
    $fh->close();

    unlink('.c4cache');
    $self->rmCache();

    return 1;
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

=back

=head1 SEE ALSO

C<P4::Client>, C<P4::C4>, 

=head1 DISTRIBUTION

The latest version is available from CPAN.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut
