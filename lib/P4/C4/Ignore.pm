# $Revision: 1.6 $$Date: 2004/11/09 13:42:38 $$Author: ws150726 $
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

package P4::C4::Ignore;
require 5.006_001;

use strict;
use vars qw($VERSION $Debug);
use Carp;
use File::Spec;
use File::Spec::Functions;
use IO::File;
use Cwd qw(getcwd);

######################################################################
#### Configuration Section

our $VERSION = '2.040';

#######################################################################
#######################################################################
#######################################################################

sub new {
    @_ >= 1 or croak 'usage: P4::C4::Ignore->new ({options})';
    my $class = shift || __PACKAGE__;		# Class (Getopt Element)
    my $self = {filename=>'.cvsignore',
		_files=>{},		# Cache by filename of raw text ignores
		_regexp=>{},		# Cache by filename of parsed ignores
		@_,
	    };
    bless $self, $class;
    $self->_addIgnore ('GLOBAL',(
				 '*~',	  '#*',    '.#*',    ',*',	   '_$*',   '*$',
				 '*.old', '*.bak', '*.BAK',  '*.orig', '*.rej', '.del-*',
				 '*.a',  '*.olb', '*.o',    '*.obj',  '*.so',  '*.exe',
				 '*.Z',  '*.elc', '*.ln',
				 'tags',	'TAGS',
				 '.make.state',	'.nse_depinfo',
				 'core',
				 # Not in CVS
				 '.dependency-info',
				 # Our own temp files
				 '.c4cache',	'.p4config',));
    
    # Read user's .cvsignore into global list
    $self->_readIgnore("GLOBAL",catfile($ENV{HOME},".cvsignore")) if defined $ENV{HOME};

    # Read CVSIGNORE environment
    $self->_addIgnore ("GLOBAL", (split /\s+/, $ENV{CVSIGNORE})) if defined $ENV{CVSIGNORE};

    return $self;
}

#######################################################################
# User methods

sub isIgnored {
    my $self = shift;
    my $filename = shift;

    $filename = File::Spec->rel2abs($filename);
    my @dirlist = File::Spec->splitdir($filename);
    while ($#dirlist > 0) {
	$filename = pop @dirlist;
	return 1 if _checkOneDir($self,catdir(@dirlist),$filename);
    }
    return 0;
}

#######################################################################
# Checking function

sub _checkOneDir {
    my $self = shift;
    my $dirname = shift;
    my $filename = shift;

    if (!$self->{_regexp}{$dirname}) {
	$self->_readIgnore($dirname, catfile($dirname,$self->{filename}));
    }

    my $basename = (File::Spec->splitpath($filename))[2];
    #print "CK1 $dirname $basename\n";
    foreach my $re (@{$self->{_regexp}{$dirname}}) {
	#print "CK1b $dirname $basename $re\n";
	return 1 if ($basename =~ /$re/);
    }
    return 0;
}

#######################################################################
# Reading functions

sub _readIgnore {
    my $self = shift;
    my $dirname = shift;
    my $filename = shift;

    return if $self->{_files}{$dirname} && $dirname ne 'GLOBAL';	# Cached
    my $fh = IO::File->new($filename,"r");
    $self->_addIgnore ($dirname, @{$self->{_files}{GLOBAL}}) if $dirname ne 'GLOBAL';
    if ($fh) {
	local $/; undef $/; my $wholefile = <$fh>;
	$self->_addIgnore ($dirname, (split /\s+/, $wholefile));
    }
}

sub _addIgnore {
    my $self = shift;
    my $dirname = shift;
    foreach my $re (@_) {
	print "  Ignore in $dirname: $re\n" if $Debug;
	if ($re eq "!") {
	    $self->{_files}{$dirname} = [];
	} else {
	    push @{$self->{_files}{$dirname}}, $re;
	}
    }

    # Convert patterns to regexp, for faster parsing
    my @relist = map { my $regexp = quotemeta $_;
		       $regexp =~ s%\\\*%.*%g;
		       $regexp =~ s%\\\?%.%g;
		       $regexp = "^".$regexp."\$";
		       qr/$regexp/;
		   } @{$self->{_files}{$dirname}};
    $self->{_regexp}{$dirname} = \@relist;
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

The L<P4::C4::Ignore> package reads .cvsignore files and provides matching
functions.

=head1 IGNORE FILES

Ignore files are mostly compatible with CVS.  The global list of ignores is
initialized with:

    *~      #*      .#*     ,*      _$*     *$
    *.old   *.bak   *.BAK   *.orig  *.rej   .del-*
    *.a     *.olb   *.o     *.obj   *.so    *.exe
    *.Z     *.elc   *.ln
    .c4cache     .p4config
    .make.state  .nse_depinfo  .dependency-info
    tags         TAGS
    core

Patterns in the home directory file ~/.cvsignore, or the CVSIGNORE
environment variable are appended to this list.

Each directory may have a local '.cvsignore' file.  The patterns found in
local `.cvsignore' are only valid for the directory that contains them, not
for any sub-directories.  

In any of the places listed above, a single exclamation mark (`!')  clears
the ignore list.  This can be used if you want to store any file which
normally is ignored.

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

=back

=head1 SEE ALSO

L<P4::C4>

=head1 DISTRIBUTION

The latest version is available from CPAN.
The latest version is available from CPAN and from L<http://www.veripool.com/>.

Copyright 2002-2004 by Wilson Snyder.  This package is free software; you
can redistribute it and/or modify it under the terms of either the GNU
Lesser General Public License or the Perl Artistic License.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut
