# $Revision: 1.13 $$Date: 2004/08/26 15:04:20 $$Author: ws150726 $
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

package P4::C4::Info;
require 5.006_001;

use strict;
use vars qw($VERSION);
use Carp;

######################################################################
#### Configuration Section

our $VERSION = '2.030';

#######################################################################
#######################################################################
#######################################################################
# Info Interface

package P4::C4::Info::UI;
use P4::C4::UI;
use strict;
our @ISA = qw( P4::C4::UI );

sub OutputInfo {
    my $self = shift;
    my $level = shift;
    my $data = shift;
    if ($level==0) {
	print __PACKAGE__.": $level: $data\n" if $P4::C4::Debug;
	if ($data =~ /^Client root:\s+(.*)$/i) {
	    $self->{c4self}{clientRoot} = $1;
	} elsif ($data =~ /^Server version:\s+(.*)$/i) {
	    $self->{c4self}{serverVersion} = $1;
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
sub _infoFetch {
    my $self = shift;
    print "_infoFetch\n" if $P4::C4::Debug;
    my $ui = new P4::C4::Info::UI(c4self=>$self);
    $self->Run($ui,'info');
}

sub clientRoot {
    my $self = shift;
    if (!$self->{clientRoot}) {
	$self->_infoFetch();
	print "clientRoot = ",$self->{clientRoot}||"","\n" if $P4::C4::Debug;
    }
    return $self->{clientRoot};  # Cached in $self
}

sub serverVersion {
    my $self = shift;
    if (!$self->{serverVersion}) {
	$self->_infoFetch();
	print "serverVersion = ",$self->{serverVersion}||"","\n" if $P4::C4::Debug;
    }
    return $self->{serverVersion};  # Cached in $self
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::Info - Perforce Info parsing

=head1 SYNOPSIS

  use P4::C4::Info;

  my $p4 = new P4::C4;
  return $p4->clientRoot();
  return $p4->serverVersion();
  ...

=head1 DESCRIPTION

This module provides utilities to operate on Perforce global information.

=head1 ACCESSORS

=over 4

=item $self->clientRoot()

Returns the root directory of the client.  Note this is cached as long
as the parent object exists.

=item $self->serverVersion()

Returns the server version of the client.  Note this is cached as long
as the parent object exists.

=back

=head1 DISTRIBUTION

The latest version is available from CPAN and from L<http://www.veripool.com/>.

Copyright 2002-2004 by Wilson Snyder.  This package is free software; you
can redistribute it and/or modify it under the terms of either the GNU
Lesser General Public License or the Perl Artistic License.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=head1 SEE ALSO

L<P4::Client>, L<P4::C4>

=cut
