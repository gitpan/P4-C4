#!/usr/local/bin/perl -w
# $Revision: 1.3 $$Date: 2004/01/27 18:59:22 $$Author: wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2002-2004 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.

use strict;
use Test;
use Cwd qw(getcwd);

BEGIN { plan tests => 4 }
BEGIN { require "t/test_utils.pl"; }

my $uppwd = getcwd();
mkdir 'test_dir', 0777;
chdir 'test_dir';

use P4::C4::Path;
ok(1);

#$P4::C4::Path::Debug = 1;

ok (P4::C4::Path::fileNoLinks('.')
    eq getcwd());
ok (P4::C4::Path::fileNoLinks('bebop/./uptoo/../../down1')
    eq getcwd()."/down1");

symlink ('..', 'to_dot_dot') ;
ok (P4::C4::Path::fileNoLinks('to_dot_dot/down1')
    eq "$uppwd/down1");


