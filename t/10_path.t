#!/usr/bin/perl -w
# $Revision: 1.6 $$Date: 2004/09/13 13:09:55 $$Author: ws150726 $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2002-2004 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.

use strict;
use Test;
use Cwd qw(getcwd);
use File::Spec::Functions;

BEGIN { plan tests => 5 }
BEGIN { require "t/test_utils.pl"; }

my $uppwd = getcwd();
mkdir 'test_dir', 0777;
chdir 'test_dir';

use P4::C4::Path;
ok(1);

#$P4::C4::Path::Debug = 1;

ok (P4::C4::Path::fileNoLinks('.')
    eq getcwd());
ok (P4::C4::Path::fileNoLinks(catfile(catdir('bebop','.','uptoo','..','..'),'down1'))
    eq catfile(getcwd(),"down1"));
ok (P4::C4::Path::fileDePerforce("foo/bar/be/bop")
    eq catfile(getcwd(),catdir("foo","bar","be","bop")));

if ($^O =~ /win/i) {
    skip(1,1); # symlink not supported on windows
} else {
    eval { symlink ('..', 'to_dot_dot') ; };
    ok (P4::C4::Path::fileNoLinks(catfile('to_dot_dot','down1'))
	eq catfile($uppwd,"down1"));
}
