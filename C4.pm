# VHier.pm -- Test running utilities
# $Revision: 1.10 $$Date: 2002/07/25 02:50:56 $$Author: wsnyder $
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
#                                                                           
######################################################################

package P4::C4;
require 5.6.0;
use File::Find;

use Carp;
use P4::Client;
# Our stuff
use P4::Getopt;
use P4::C4::Cache;
use P4::C4::Client;
use P4::C4::Diff;
use P4::C4::File;
use P4::C4::Fstat;
use P4::C4::Ignore;
use P4::C4::Info;
use P4::C4::Path;
use P4::C4::Submit;
use P4::C4::Sync;
use P4::C4::UI;
use P4::C4::Update;
use P4::C4::User;

use strict;
use vars qw($Debug $VERSION);

our @ISA = qw (P4::Client);

######################################################################
#### Configuration Section

$VERSION = '2.000';

######################################################################
#### Creators

sub new {
    my $class = shift;
    my %params = (_files=>{},
		  @_);
    my $self = new P4::Client;
    bless ($self, $class);

    while ((my $key,my $val) = each %params) {
	$self->{$key} = $val;
    }
    if ($self->{opt}) {
	$self->{opt}->setClientOpt($self);
    }
    return $self;
}

######################################################################
#### Accessors

sub files {
    return $_[0]->{_files};
}

######################################################################
#### Package return
1;
=pod

=head1 NAME

P4::C4 - CVS Like wrapper for Perforce

=head1 SYNOPSIS

  use P4::C4;

=head1 DESCRIPTION

P4::C4 is a derrived class of C4::Client.  The various P4::C4::... classes
add member functions to this class to perform various functions.

=head1 FUNCTIONS

=over 4

=item $self->files

Return a hash of file structures, where the key is the name of the
file. Used by P4::C4::Files and other functions.

=back

=head1 SEE ALSO

C<c4>, C<p4>

C<P4::Client>
C<P4::Getopt>
C<P4::C4::UI>

C<P4::C4::Cache>
C<P4::C4::Client>
C<P4::C4::Diff>
C<P4::C4::File>
C<P4::C4::Fstat>
C<P4::C4::Ignore>
C<P4::C4::Info>
C<P4::C4::Path>
C<P4::C4::Submit>
C<P4::C4::Sync>
C<P4::C4::Update>
C<P4::C4::User>

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut
######################################################################
