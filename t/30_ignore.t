#!/usr/bin/perl -w
# $Revision: 1.5 $$Date: 2004/07/19 22:57:37 $$Author: wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2002-2004 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.

use strict;
use Test;
use Cwd;

BEGIN { plan tests => 7 }
BEGIN { require "t/test_utils.pl"; }

use P4::C4::Ignore;
ok(1);

#$P4::C4::Ignore::Debug = 1;

my $ign = new P4::C4::Ignore;
ok(1);

ok(!$ign->isIgnored("Ignore.pm"));
ok($ign->isIgnored("core"));
ok($ign->isIgnored("foo.o"));
ok($ign->isIgnored("foo.bs"));
ok($ign->isIgnored("Makefile"));
