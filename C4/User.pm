# $Revision: 1.12 $$Date: 2004/08/26 15:04:20 $$Author: ws150726 $
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

package P4::C4::User;
require 5.006_001;

use strict;
use vars qw($VERSION);
use Carp;

######################################################################
#### Configuration Section

$VERSION = '2.030';

#######################################################################
#######################################################################
#######################################################################
# User Interface

package P4::C4::User::IsUI;
use P4::C4::UI;
use strict;
our @ISA = qw( P4::C4::UI );

sub OutputInfo {
    my $self = shift;
    my $level = shift;
    my $data = shift;
    if ($level==0) {
	print __PACKAGE__.": $level: $data\n" if $P4::C4::Debug;
	if ($data =~ /^$self->{user}\s/) {
	    $self->{status} = $data;
	}
    } else {
	die "$0: %Error: Bad p4 response: $data\n";
    }
}

#######################################################################
#######################################################################
#######################################################################
# OVERRIDE METHODS

package P4::Client;
sub isUser {
    my $self = shift;
    my $user = shift;
    # Return true if user exists
    print "isUser $user" if $P4::C4::Debug;
    my $ui = new P4::C4::User::IsUI (user=>$user);
    $self->Users($ui);
    return $ui->{status}
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::User - User utilities

=head1 SYNOPSIS

  use P4::C4::User;

  my $p4 = new P4::Client;
  $p4->isUser("foo");
  ...

=head1 DESCRIPTION

This module provides utilities to operate on Perforce users.

=head1 ACCESSORS

There is a accessor for each parameter listed above.  In addition:

=over 4

=item $self->isUser ( \$username )

Returns true if the user exists.

=back

=head1 DISTRIBUTION

The latest version is available from CPAN and from L<http://www.veripool.com/>.

Copyright 2002-2004 by Wilson Snyder.  This package is free software; you
can redistribute it and/or modify it under the terms of either the GNU
Lesser General Public License or the Perl Artistic License.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=head1 SEE ALSO

L<P4::Client>, L<P4::C4>, 

=cut
