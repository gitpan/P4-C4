# $Revision: 1.9 $$Date: 2003/08/06 15:29:58 $$Author: wsnyder $
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

package P4::C4::UI;
use P4::UI;
use strict;
use vars qw($VERSION);
our @ISA = qw( P4::UI );

$VERSION = '2.020';

sub new {
    my $class = shift;
    my $self = { @_ };
    bless ($self, $class);
    return $self;
}

sub OutputInfo($$) {
    my ($self, $level, $data) = @_;
    $data =~ s/\.$//;
    return if $data =~ /- was edit, reverted/;
    return if $data =~ /- opened for edit/;
    return if $data =~ /- refreshing /;
    return if $data =~ /- deleted as /;
    return if $data =~ /^Client .* saved$/;
    return if $data =~ /^Client .* deleted$/;
    return if $data =~ /^Client .* not changed$/;
    warn "$0: %Warn: Unexpected P4 Response: $data\n" if $P4::C4::Debug;
}

sub OutputError($) {
    my ($self, $err) = @_;
    return if $err =~ /- file.s. up-to-date/;
    return if $err =~ /not opened on this client/ && $self->{noneOpenOk};
    return if $err =~ /File\(s\) not in client view/ && $self->{noneOpenOk};
    die "$0: %Error: P4 Error: $err\n";
}

######################################################################
### Package return
1;
__END__

=pod

=head1 NAME

P4::C4::UI - User Interface class

=head1 SYNOPSIS

=head1 DESCRIPTION

This module is derived from P4::UI for internal P4::C4 use.  It is a basic
user interface client, but supports hashed arguments in the new
constructor.  It's default callbacks die on errors instead of just printing
them.

=head1 SEE ALSO

C<P4::UI>, C<P4::C4>, 

=head1 DISTRIBUTION

The latest version is available from CPAN.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=cut
