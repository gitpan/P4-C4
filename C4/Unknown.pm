# $Revision: 1.6 $$Date: 2004/08/26 15:04:20 $$Author: ws150726 $
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

package P4::C4::Unknown;
use strict;

our $VERSION = '2.030';

######################################################################
######################################################################
######################################################################
#### Package overrides

package P4::C4;
use P4::C4::Info;
use P4::C4::Cache;
use P4::C4::Ignore;
use P4::C4::Diff;
use P4::C4::Sync;
use Data::Dumper;
use strict;

sub unknown {
    my $self = shift;
    my @params = @_;

    $self->clientRoot or die "%Error: Not inside a client spec, cd to inside one.\n";

    my @files;
    foreach my $param (@params) {
	if ($param =~ /^-/) {
	    die "%Error: Unrecognized 'c4 unknown' parameter: $param\n";
	} else {
	    push @files, P4::C4::Path::fileDePerforce($param);
	}
    }

    push @files, $self->clientRoot if $#files<0;

    # Grab status
    foreach my $file (@files) {
	$self->findFiles($file);
	$self->fstatFiles($file);
    }

    # Print stats
    $self->ignoredFiles();
    foreach my $fref (sort {$a->{filename} cmp $b->{filename}}
		      (values %{$self->{_files}})) {
	next if $fref->{action};
	my $stat = $fref->{status};  # May be defined or not
	$stat ||= '?-    ' if ($fref->{unknown});
	if ($stat) {
	    $stat =~ s/-.*$// if !$P4::C4::Debug;
	    print $stat." ".$fref->{filename}."\n";
	}
    }
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::Unknown - Print unknown files

=head1 DESCRIPTION

This module implements the C4 unknown command.

=head1 DISTRIBUTION

The latest version is available from CPAN and from L<http://www.veripool.com/>.

Copyright 2002-2004 by Wilson Snyder.  This package is free software; you
can redistribute it and/or modify it under the terms of either the GNU
Lesser General Public License or the Perl Artistic License.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=head1 SEE ALSO

L<P4::C4>

=cut
