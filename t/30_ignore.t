#!/usr/bin/perl -w
# $Revision: 1.6 $$Date: 2004/11/09 13:32:15 $$Author: ws150726 $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2002-2004 by Wilson Snyder.  This program is free software;
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
