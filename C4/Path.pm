# $Revision: 1.9 $$Date: 2004/01/27 18:59:22 $$Author: wsnyder $
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
use Cwd qw(getcwd);
use strict;

require Exporter;
our @ISA = ('Exporter');
our @EXPORT = qw( fileNoLinks );
our $VERSION = '2.021';

######################################################################

sub fileDePerforce {
    my $filename = shift;
    # Strip perforce specifics
    $filename =~ s/\.\.\.$//;
    $filename =~ s/\/$//;
    return fileNoLinks($filename);
}

sub fileNoLinks {
    my $filename = shift;
    # Remove any symlinks in the filename
    # Perforce doesn't allow "cd ~/sim/project" where project is a symlink!
    # Modified example from the web
	
    my @right = split /\//, $filename;
	
    if ($right[0] ne "") {  # relative
	unshift @right, split /\//, getcwd();
    }
    my @left = shift @right;  # Should be empty, as we're absolute

    while (@right) {
	#print "PARSE: ",join("/",@left),"  --- ",join("/",@right),"\n";
	my $item = shift @right;
	next if $item eq "." or $item eq "";
	
	if ($item eq "..") {
	    pop @left if @left > 1;
	    next;
	}
	    
	my $link = readlink (join "/", @left, $item);
	    
	if (defined $link) {
	    my @parts = split /\//, $link;
	    if (@parts && ($parts[0] eq "")) { # absolute
		@left = shift @parts;   # quick way
	    }
	    unshift @right, @parts;
	    next;
	} else {
	    push @left, $item;
	    next;
	}
    }
    my $out = join("/", @left);
    #print "ABS: $out\n";
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

=back

=head1 SEE ALSO

C<P4::C4>, 

=head1 DISTRIBUTION

The latest version is available from CPAN.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut
