# $Revision: 1.5 $$Date: 2004/11/09 13:42:38 $$Author: ws150726 $
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

package P4::C4::Submit;
require 5.006_001;

use P4::Getopt;
use P4::C4::Cache;
use P4::C4::Path;
use strict;
use Carp;

######################################################################
#### Configuration Section

our $VERSION = '2.040';

#######################################################################
#######################################################################
#######################################################################
# OVERRIDE METHODS

package P4::C4;
sub submitCheckC4 {
    my $self = shift;
    my @params = @_;
    # Submit areas under p4 control; check c4 that all adds have been done.
    # Doesn't do the actual submit though.

    $self->clientRoot or die "%Error: Not inside a client spec, cd to inside one.\n";

    my @files;
    my $force;

    my @cmdParsed = P4::Getopt->parseCmd('submit', @params);
    for (my $i=0; $i<=$#cmdParsed; $i++) {
	if ($params[$i] eq '-f') {
	    $force = 1;
	}
	elsif ($cmdParsed[$i] =~ /^file/
	       && !P4::C4::Path::isDepotFilename($params[$i])) {
	    push @files, P4::C4::Path::fileDePerforce($params[$i]);
	}
    }

    push @files, $self->clientRoot if $#files<0;

    # Grab status
    $self->readCache();
    foreach my $file (@files) {
	$self->findFiles($file);
    }
    $self->ignoredFiles();

    foreach my $fref (sort {$a->{filename} cmp $b->{filename}}
		      (values %{$self->{_files}})) {
	next if $fref->{ignore};
	if ($fref->{clientMtime}   # Else might not be checking in this file.  Small danger of a missing "rm" but that's unlikely
	    && ($fref->{oldMtime}||0) != ($fref->{clientMtime}||0)) {
	    print "File date off $fref->{filename}\n" if $P4::C4::Debug;
	    die "%Error: Must c4 update again before submitting (due to $fref->{filename})\n" if !$force;
	}
    }
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::Submit - Perforce Submit parsing

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
