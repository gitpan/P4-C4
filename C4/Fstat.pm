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

package P4::C4::Fstat;
require 5.6.0;

use strict;
use vars qw($VERSION);
use Carp;

######################################################################
#### Configuration Section

$VERSION = '2.000';

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
	$fref->{depotExists} = $fref->{depotFile}
                  && (($fref->{headAction}||'') eq 'add'
		      || ($fref->{headAction}||'') eq 'branch'
		      || ($fref->{headAction}||'') eq 'edit');
    }
}

#######################################################################
#######################################################################
#######################################################################
# OVERRIDE METHODS

package P4::C4;
sub fstatFiles {   # Regular routine called fstat
    my $self = shift;
    my $filename = shift;
    # Return true if user exists
    $filename .= "/..." if -d $filename;
    print "fstat $filename\n" if $P4::C4::Debug;
    my $ui = new P4::C4::Fstat::UI(c4self=>$self);
    $self->Fstat($ui, "$filename");
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

=head1 SEE ALSO

C<P4::Client>, C<P4::C4>, 

=head1 DISTRIBUTION

The latest version is available from CPAN.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut
