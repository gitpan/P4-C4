# $Revision: 1.3 $$Date: 2002/07/24 20:00:27 $$Author: wsnyder $
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

package P4::C4::Sync;
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
# Sync Interface

package P4::C4::Sync::UI;
use P4::C4::UI;
use strict;
our @ISA = qw( P4::C4::UI );

sub OutputInfo {
    my $self = shift;
    my $level = shift;
    my $data = shift;
    if ($data =~ /- updating (\S+)/) {
	$self->{c4self}{_files}{$1}{filename} = $1;
	my $fref = $self->{c4self}{_files}{$1};
	$fref->{updated} = 1;
	$fref->{status} = 'C-sync' if ($fref->{status});
	$fref->{status} ||= 'U-sync';
    } elsif ($data =~ /(\S+) - must resolve/) {
    } else {
	print __PACKAGE__.": $level: $data\n" if $P4::C4::Debug;
    }
}

#######################################################################
#######################################################################
#######################################################################
# OVERRIDE METHODS

package P4::C4;
sub syncFiles {   # Regular routine called sync
    my $self = shift;
    my @params = @_;
    # Sync specified areas
    for (my $i=0; $i<=$#params; $i++) {
	$params[$i] .= "/..." if -d $params[$i];
    }
    print "sync @params\n" if $P4::C4::Debug;
    my $ui = new P4::C4::Sync::UI(c4self=>$self);
    $self->Run($ui, 'sync', @params);
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::Sync - Perforce Sync parsing

=head1 DESCRIPTION

This module is for internal P4::C4 use.

=head1 SEE ALSO

C<P4::Client>, C<P4::C4>, 

=head1 DISTRIBUTION

The latest version is available from CPAN.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut
