# $Revision: 1.4 $$Date: 2002/08/08 13:35:38 $$Author: wsnyder $
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

package P4::C4::Diff;
require 5.6.0;

use strict;
use vars qw($VERSION);
use Carp;

######################################################################
#### Configuration Section

$VERSION = '2.000';

#######################################################################
#######################################################################
#######################################################################
# Diff Interface

package P4::C4::Diff::UI;
use P4::C4::UI;
use strict;
our @ISA = qw( P4::C4::UI );

sub OutputInfo {
    my $self = shift;
    my $level = shift;
    my $data = shift;
    return if ($data =~ /^==== /);
}

sub Diff {
    my $self = shift;
    my $f1 = shift;
    my $f2 = shift;
    my $flags = shift;
    my $diff = shift;
    $self->{differs} = $diff;
    print __PACKAGE__.": DIFFERS $diff\n" if $P4::C4::Debug;
}

#######################################################################
#######################################################################
#######################################################################
# OVERRIDE METHODS

package P4::C4;
sub differentFiles {   # Regular routine called diff
    my $self = shift;
    my @params = @_;

    # Return true if user exists
    print "diff @params\n" if $P4::C4::Debug;
    my $ui = new P4::C4::Diff::UI(c4self=>$self);
    $self->Run($ui,'diff', @params);
    print "  Does differ @params\n" if $P4::C4::Debug && $ui->{differs};
    return $ui->{differs};
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::Diff - Perforce Diff parsing

=head1 SYNOPSIS

  use P4::C4::Diff;

  my $p4 = new P4::C4;
  $p4->differentFiles (<params>)
  ...

=head1 DESCRIPTION

This module provides utilities to retrieve Perforce difference information.

=head1 METHODS

=over 4

=item $self->differentFiles ( args )

Run a P4 diff operation with the given arguments, and return true if the
files differ in any way.

=back

=head1 SEE ALSO

C<P4::Client>, C<P4::C4>, 

=head1 DISTRIBUTION

The latest version is available from CPAN.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut
