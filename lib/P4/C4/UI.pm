# $Revision: 1.4 $$Date: 2004/11/09 13:42:38 $$Author: ws150726 $
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

package P4::C4::UI;
use P4::UI;
use strict;
our @ISA = qw( P4::UI );

our $VERSION = '2.040';

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

=head1 DISTRIBUTION

The latest version is available from CPAN and from L<http://www.veripool.com/>.

Copyright 2002-2004 by Wilson Snyder.  This package is free software; you
can redistribute it and/or modify it under the terms of either the GNU
Lesser General Public License or the Perl Artistic License.

=head1 AUTHORS

Wilson Snyder <wsnyder@wsnyder.org>

=head1 SEE ALSO

L<P4::UI>, L<P4::C4>

=cut
