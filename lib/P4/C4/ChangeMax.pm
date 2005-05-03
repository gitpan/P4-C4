# $Revision: 709 $$Date: 2005-05-03 17:32:07 -0400 (Tue, 03 May 2005) $$Author: wsnyder $
# Author: Wilson Snyder <wsnyder@wsnyder.org>
######################################################################
#
# Copyright 2002-2005 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
######################################################################

package P4::C4::ChangeMax;
use strict;

our $VERSION = '2.041';

#######################################################################
#######################################################################
#######################################################################
# ChangeMax Interface

package P4::C4::ChangeMax::UI;
use P4::C4::UI;
use strict;
our @ISA = qw( P4::C4::UI );

sub OutputInfo($$) {
    my ($self, $level, $data) = @_;
    if ($data =~ /\s+-\s+.*\s+change\s+(\d+)/) {
	my $chgnum = $1;
	if (!$self->{maxChange} || $chgnum > $self->{maxChange}) {
	    $self->{maxChange} = $chgnum;
	}
    } else {
	warn "$0: %Warn: Unexpected P4 Response: $data\n" if $P4::C4::Debug;
    }
}

######################################################################
######################################################################
######################################################################
#### Package overrides

package P4::C4;
use P4::C4::Info;
use Data::Dumper;
use strict;

sub changeMax {
    my $self = shift;
    my @params = @_;

    $self->clientRoot or die "%Error: Not inside a client spec, cd to inside one.\n";

    my @files;
    foreach my $param (@params) {
	if ($param =~ /^-/) {
	    die "%Error: Unrecognized 'c4 change-max' parameter: $param\n";
	} else {
	    push @files, P4::C4::Path::fileDePerforce($param);
	}
    }

    push @files, $self->clientRoot if $#files<0;

    # Grab status
    my $ui = new P4::C4::ChangeMax::UI(c4self=>$self);
    foreach my $filename (@files) {
	$filename = catfile($filename,"...") if -d $filename;
	$self->Files($ui, $filename);
    }

    return $ui->{maxChange};
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::ChangeMax - Return maximum change number

=head1 DESCRIPTION

This module returns the maximum change number of the specified files.

=head1 DISTRIBUTION

The latest version is available from CPAN and from L<http://www.veripool.com/>.

Copyright 2002-2005 by Wilson Snyder.  This package is free software; you
can redistribute it and/or modify it under the terms of either the GNU
Lesser General Public License or the Perl Artistic License.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=head1 SEE ALSO

L<P4::C4>

=cut
