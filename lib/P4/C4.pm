# VHier.pm -- Test running utilities
# $Revision: 1.4 $$Date: 2004/10/15 14:16:42 $$Author: ws150726 $
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

package P4::C4;
require 5.006_001;
use File::Find;

use Carp;
use P4::Client;
# Our stuff
use P4::Getopt;
use P4::C4::Cache;
use P4::C4::ChangeMax;
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
use P4::C4::Unknown;
use P4::C4::Update;
use P4::C4::User;

use strict;
use vars qw($Debug $VERSION);

our @ISA = qw (P4::Client);

######################################################################
#### Configuration Section

$VERSION = '2.032';

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

P4::C4 is a derived class of C4::Client.  The various P4::C4::... classes
add member functions to this class to perform various functions.

=head1 FUNCTIONS

=over 4

=item $self->files

Return a hash of file structures, where the key is the name of the
file. Used by P4::C4::Files and other functions.

=back

=head1 DISTRIBUTION

The latest version is available from CPAN and from L<http://www.veripool.com/>.

Copyright 2002-2004 by Wilson Snyder.  This package is free software; you
can redistribute it and/or modify it under the terms of either the GNU
Lesser General Public License or the Perl Artistic License.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=head1 SEE ALSO

L<c4>, L<p4>, L<p4_job_edit>

L<P4::Client>,
L<P4::Getopt>,

L<P4::C4::UI>,
L<P4::C4::Cache>,
L<P4::C4::Client>,
L<P4::C4::Diff>,
L<P4::C4::File>,
L<P4::C4::Fstat>,
L<P4::C4::Ignore>,
L<P4::C4::Info>,
L<P4::C4::Path>,
L<P4::C4::Submit>,
L<P4::C4::Sync>,
L<P4::C4::Update>,
L<P4::C4::User>

=cut
######################################################################
