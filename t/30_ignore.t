#!/usr/local/bin/perl -w
# $Revision: 1.2 $$Date: 2002/07/23 01:42:18 $$Author: wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package

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
