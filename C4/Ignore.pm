# $Revision: 1.5 $$Date: 2002/07/25 02:50:56 $$Author: wsnyder $
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

package P4::C4::Ignore;
require 5.6.0;

use strict;
use vars qw($VERSION $Debug);
use Carp;
use IO::File;
use Cwd qw(getcwd);

######################################################################
#### Configuration Section

$VERSION = '2.000';

#######################################################################
#######################################################################
#######################################################################

sub new {
    @_ >= 1 or croak 'usage: P4::C4::Ignore->new ({options})';
    my $class = shift || __PACKAGE__;		# Class (Getopt Element)
    my $self = {filename=>'.cvsignore',
		_files=>{},		# Cache by filename of parsed ignores
		@_,
	    };
    bless $self, $class;
    $self->_addIgnore ('GLOBAL',(
				 'tags',    'TAGS',
				 '.make.state',     '.nse_depinfo',
				 '*~',	  '#*',    '.#*',    ',*',	   '_$*',   '*$',
				 '*.old', '*.bak', '*.BAK',  '*.orig', '*.rej', '.del-*',
				 '*.a',  '*.olb', '*.o',    '*.obj',  '*.so',  '*.exe',
				 '*.Z',  '*.elc', '*.ln',
				 'core',
				 #
				 '.c4cache', '.p4config',));
    return $self;
}

#######################################################################
# User methods

sub isIgnored {
    my $self = shift;
    my $filename = shift;

    $filename = getcwd()."/".$filename if $filename !~ m%^/%;
    return 1 if _checkOneDir($self,'GLOBAL',$filename);
    while ($filename =~ m%(.*)/([^\/]*)$%) {
	return 1 if _checkOneDir($self,$1,$filename);
	$filename = $1;
    }
    return 0;
}

#######################################################################
# Checking function

sub _checkOneDir {
    my $self = shift;
    my $dirname = shift;
    my $filename = shift;
    
    if (!$self->{_files}{$dirname}) {
	$self->_readIgnore($dirname);
    }
    
    (my $basename = $filename) =~ s%.*\/%%g;
    #print "CK1 $dirname $basename\n";
    foreach my $re (@{$self->{_files}{$dirname}}) {
	return 1 if ($basename =~ /$re/);
    }
    return 0;
}

#######################################################################
# Reading functions

sub _readIgnore {
    my $self = shift;
    my $dirname = shift;
    
    return if $self->{_files}{$dirname};	# Cached
    my $fh = IO::File->new($dirname."/".$self->{filename},"r");
    $self->{_files}{$dirname} = [];
    if ($fh) {
	local $/; undef $/; my $wholefile = <$fh>;
	$self->_addIgnore ($dirname, (split /\s+/, $wholefile));
    }
}

sub _addIgnore {
    my $self = shift;
    my $dirname = shift;
    foreach my $re (@_) {
	my $regexp = quotemeta $re;
	$regexp =~ s%\\\*%.*%g;
	$regexp =~ s%\\\?%.%g;
	$regexp = "^".$regexp."\$";
	print "  Ignore in $dirname: $regexp\n" if $Debug;
	push @{$self->{_files}{$dirname}}, qr/$regexp/;
    }
}

######################################################################
######################################################################
######################################################################
######################################################################
# Overrides

package P4::C4;
use strict;

sub ignoredFiles {
    my $self = shift;

    $self->{_ignore} = new P4::C4::Ignore() if !$self->{_ignore};
    foreach my $fref (values %{$self->{_files}}) {
	if ($fref->{clientMtime}
	    && !($fref->{headAction} && $fref->{headAction} ne 'delete')
	    && !$fref->{ignore}) {
	    #use Data::Dumper; print "check",Dumper($fref) if $fref->{filename} =~ /c4cache/;
	    $fref->{ignore} = $self->{_ignore}->isIgnored($fref->{filename});
	    $fref->{unknown} = 1 if !$fref->{ignore};
	}
    }
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::Ignore - Read a cvs ignore file

=head1 SYNOPSIS

  use P4::C4::Ignore;

  my $ign = new P4::C4::Ignore();
  $ign->isIgnored ($filename);

  ...

=head1 DESCRIPTION

The C<P4::C4::Ignore> package reads .cvsignore files and provides matching
functions.

=head1 IGNORE FILES

Ignore files are mostly compatible with CVS.  The list of ignores is
initialized with:

              tags    TAGS
              .make.state     .nse_depinfo
              *~      #*      .#*     ,*      _$*     *$
              *.old   *.bak   *.BAK   *.orig  *.rej   .del-*
              *.a     *.olb   *.o     *.obj   *.so    *.exe
              *.Z     *.elc   *.ln
              core

The patterns found in `.cvsignore' are only valid for the directory that
contains them, not for any sub-directories.  A single exclamation mark
(`!')  clears the ignore list.

The wildcards * and ? are honored, no other wildcards are currently
supported.

=head1 METHODS

=over 4

=item $ign = P4::C4::Ignore->new ( I<opts> )

Create a new Ignore hash.  "filename=>I<filename>" may be specified to
override the default of .cvsignore for reading the ignore file.

Any .cvsignore files that are read are cached in this object to save time.
Thus if a .cvsignore file is being written by the application, a new object
will have to be created to clear the hash.

=item $self->is_ignored ( $file )

Returns true if the file is being ignored.

=head1 SEE ALSO

C<P4::C4>, 

=head1 DISTRIBUTION

The latest version is available from CPAN.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut
