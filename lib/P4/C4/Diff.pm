# $Revision: 1.4 $$Date: 2004/11/09 13:42:38 $$Author: ws150726 $
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

package P4::C4::Diff;
require 5.006_001;

use strict;
use Carp;

######################################################################
#### Configuration Section

our $VERSION = '2.040';

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
    $self->DoPerlDiffs();
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
