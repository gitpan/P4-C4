#!/usr/bin/perl -w
# $Revision: 709 $$Date: 2005-05-03 17:32:07 -0400 (Tue, 03 May 2005) $$Author: wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2002-2005 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.

use strict;
use Test;
use Cwd;

BEGIN { plan tests => 12 }
BEGIN { require "t/test_utils.pl"; }

use P4::C4::Ignore;
ok(1);

#$P4::C4::Ignore::Debug = 1;

{
    my $ign = new P4::C4::Ignore;
    ok($ign);

    ok(!$ign->isIgnored("Ignore.pm"));
    ok($ign->isIgnored("core"));
    ok($ign->isIgnored("foo.o"));
    ok($ign->isIgnored("foo.bs"));
    ok($ign->isIgnored("Makefile"));
}

{
    $ENV{CVSIGNORE} = "! ignoreme metoo";

    my $ign = new P4::C4::Ignore;
    ok($ign);

    ok(!$ign->isIgnored("foo.o"));  # Global *.o no longer applies
    ok($ign->isIgnored("foo.bs"));
    ok($ign->isIgnored("ignoreme"));
    ok($ign->isIgnored("metoo"));
}
