# $Revision: 1.4 $$Date: 2004/10/15 14:16:42 $$Author: ws150726 $
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

package P4::C4::Fstat;
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
# Fstat Interface

package P4::C4::Fstat::UI;
use P4::C4::UI;
use strict;
our @ISA = qw( P4::C4::UI );

sub OutputStat {
    my $self = shift;
    my $hash = shift;
    my $newrec = {};
    # There is a bug in the library, we can't get the other open user's names.
    if ($hash->{clientFile}) {
	$self->{c4self}{_files}{ $hash->{clientFile} }{filename} = $hash->{clientFile};
	my $fref = $self->{c4self}{_files}{ $hash->{clientFile} };
	while ((my $key,my $val) = each %$hash) {
	    if (ref($val)){
		foreach my $item (@{$val}) {
		#    print( "... $item\n" );
		}
	    } else {
		$fref->{$key} = $val;
	    }
	}
	# add, branch, edit, integrate
	$fref->{depotExists} = ($fref->{depotFile}
				&& $fref->{headAction}
				&& (($fref->{headAction}||'') ne 'delete'));
    }
}

#######################################################################
#######################################################################
#######################################################################
# OVERRIDE METHODS

package P4::C4;
use File::Spec::Functions;
sub fstatFiles {   # Regular routine called fstat
    my $self = shift;
    my $filename = shift;
    # Return true if user exists
    $filename = catfile($filename,"...") if -d $filename;
    print "fstat $filename\n" if $P4::C4::Debug;
    my $ui = new P4::C4::Fstat::UI(c4self=>$self);
    $self->Fstat($ui, $filename);
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::Fstat - Perforce Fstat parsing

=head1 SYNOPSIS

  use P4::C4::Fstat;

  my $p4 = new P4::C4;
  ...

=head1 DESCRIPTION

This module provides utilities to retrieve Perforce fstat information.

=head1 METHODS

=over 4

=item $self->fstatFiles (args)

Run a p4 fstat with the given arguments, and load $self->files with a
hash of the name of the file and each fstat parameter.

=back

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
