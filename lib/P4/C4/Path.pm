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

package P4::C4::Path;
use File::Spec;
use File::Spec::Functions;
use Cwd qw(getcwd);
use strict;

require Exporter;
our @ISA = ('Exporter');
our @EXPORT = qw( fileNoLinks );
our $VERSION = '2.040';

######################################################################

sub isDepotFilename {
    my $filename = shift;
    return ($filename =~ m%^//%);
}

sub fileDePerforce {
    my $filename = shift;
    # Strip perforce specifics
    $filename =~ s/\.\.\.$//;
    $filename =~ s![/\\]$!!;
    # On Windows, Repositories always use / but filenames want backslashes
    # We'll take either, then make them native
    my @dirs = split /[\\\/]/, $filename;
    return fileNoLinks(catfile(@dirs));
}

sub fileNoLinks {
    my $filename = shift;
    # Remove any symlinks in the filename
    # Perforce doesn't allow "cd ~/sim/project" where project is a symlink!
    # Modified example from the web
	
    #print "FNLinp: $filename\n";
    $filename = File::Spec->rel2abs($filename);
    my @right = File::Spec->splitdir($filename);
    my @left;

    while (@right) {
	#print "PARSE: ",catfile(@left),"  --- ",catfile(@right),"\n";
	my $item = shift @right;
	next if $item eq ".";
	if ($item eq "") {
	    push @left, $item;
	    next;
	}
	elsif ($item eq "..") {
	    pop @left if @left > 1;
	    next;
	}
	    
	my $link = readlink (catfile(@left, $item));
	    
	if (defined $link) {
	    if (file_name_is_absolute($link)) {
		@left = File::Spec->splitdir($link);
	    } else {
		unshift @right, File::Spec->splitdir($link);
	    }
	    # Start search over, as we might have more links to resolve
	    unshift @right, @left;
	    @left = ();
	    next;
	} else {
	    push @left, $item;
	    next;
	}
    }
    my $out = catfile(@left);
    #print "FNLabs: $out\n";
    return $out;
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::Path - File path and parsing utilities

=head1 SYNOPSIS

   my $file = fileDePerforce($filename)
   my $file = fileNoLinks($filename)

=head1 DESCRIPTION

This module provides operations on files and paths.

=head1 METHODS

=over 4

=item $self->fileDePerforce($filename)

Convert the Perforce file specification to a local filename, by
removing any ...'s, and symlinks. 

=item $self->fileNoLinks($filename)

Resolve any symlinks in the given filename.

=item $self->isDepotFilename($filename)

Return true if the filename is a absolute depot file name.

=back

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
