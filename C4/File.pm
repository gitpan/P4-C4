# $Revision: 1.6 $$Date: 2002/07/24 17:53:13 $$Author: wsnyder $
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

package P4::C4::File;
use DirHandle;
use strict;

sub new {
    my $class = shift;
    my $self = { @_ };
    bless ($self, $class);
    return $self;
}

######################################################################
######################################################################
######################################################################
#### Package overrides

package P4::C4;
use Fcntl ':mode';	# S_ stat functions
use strict;

sub findFiles {
    my $self = shift;
    my $file = shift;
    print "findFiles($file)\n" if $P4::C4::Debug;
    if (-d $file || -r $file) {  # check, otherwise it might not exist;
	_findFilesRecurse($self,$file);
    }
}

sub _findFilesRecurse {
    my $self = shift;
    my $dir = shift;
    #print "  Dir $dir\n" if $P4::C4::Debug;

    my @st = lstat $dir;
    #dev ino mode nlink uid gid rdev size atime mtime ctime blksize blocks.

    if (S_ISDIR($st[2])) {
	my $dh = new DirHandle $dir or die "%Error: $! $dir\n";
	my @files;
	while (defined (my $basefile = $dh->read)) {
	    if (($basefile ne ".") && ($basefile ne "..")) {
		my $file = "$dir/$basefile";
		push @files, $file;
	    }
	}
	$dh->close();
	# It's faster for the disk to read the whole directory, then operate on it.
	foreach my $file (@files) {
	    _findFilesRecurse($self, $file);
	}
	return;
    }

    # Regular file
    $self->{_files}{$dir}{filename} = $dir;
    $self->{_files}{$dir}{clientType} = S_ISLNK($st[2])?"symlink":"text";
    $self->{_files}{$dir}{clientMtime} = $st[9];
    #use Data::Dumper; print Dumper($self->{_files}{$dir});
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::File - Information on one C4 tracked file

=head1 DESCRIPTION

This module is for internal P4::C4 use.

=head1 SEE ALSO

C<P4::C4>, 

=head1 DISTRIBUTION

The latest version is available from CPAN.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut
