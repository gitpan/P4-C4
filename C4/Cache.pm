# $Revision: 1.3 $$Date: 2002/07/24 15:32:53 $$Author: wsnyder $
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

package P4::C4::Cache;

######################################################################
######################################################################
######################################################################
#### Package overrides

package P4::C4;
use P4::C4::Info;
use Data::Dumper;
use strict;

our $CurrentSelf;

sub rmCache {
    my $self = shift;
    # Remove the cache
    my $filename = $self->clientRoot."/.c4cache";
    unlink $filename;
}

sub readCache {
    my $self = shift;
    # Read the .c4cache into _files

    my $filename = $self->clientRoot."/.c4cache";
    if (-r $filename) {
	print "readCache($filename)\n" if $P4::C4::Debug;
	$CurrentSelf = $self;  # As self isn't known by the "do"
	$! = $@ = undef;
	my $rtn = do $filename;
	(!$@ && $rtn==1) or die "%Error: $filename: $@ / $!\n";
	print "readCacheDone($filename)\n" if $P4::C4::Debug;
    }
}

sub writeCache {
    my $self = shift;
    # Write the .c4cache

    my $filename = $self->clientRoot."/.c4cache";
    my $fh = IO::File->new($filename,"w") or return;  # It's just a cache, after all
    print "writeCache($filename)\n" if $P4::C4::Debug;
    foreach my $file (sort (keys %{$self->{_files}})) {
	my $fref = $self->{_files}{$file};
	(my $filequote = $file) =~ s/\'/\\\'/g;
	print $fh "addCacheFile('$filequote',";
	print $fh "oldMtime=>",$fref->{clientMtime} if $fref->{clientMtime};
	print $fh ");\n";
    }
    print $fh "1;\n";
    $fh->close;
}

sub addCacheFile {
    my $self = $CurrentSelf;
    my $filename = shift;
    my %params = (@_);
    # Called by the cached file to add information to the given file's structure
    $self->{_files}{$filename}{filename} = $filename;
    while ((my $key,my $val) = each %params) {
	$self->{_files}{$filename}{$key} = $val;
    }
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::Cache - Caching of file information for Ct

=head1 SYNOPSIS

=head1 DESCRIPTION

This module is for managing file caches for internal P4::C4 use.

=head1 SEE ALSO

C<P4::C4>, 

=head1 DISTRIBUTION

The latest version is available from CPAN.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut
