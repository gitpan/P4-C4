# $Revision: 1.3 $$Date: 2004/10/15 14:16:42 $$Author: ws150726 $
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

package P4::C4::Sync;
require 5.006_001;

use strict;
use vars qw($VERSION);
use Carp;

######################################################################
#### Configuration Section

$VERSION = '2.032';

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
use File::Spec::Functions;
sub syncFiles {   # Regular routine called sync
    my $self = shift;
    my @params = @_;
    # Sync specified areas
    for (my $i=0; $i<=$#params; $i++) {
	$params[$i] = catfile($params[$i],"...") if -d $params[$i];
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
