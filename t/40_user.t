#!/usr/local/bin/perl -w
# $Revision: 1.4 $$Date: 2004/01/27 18:59:22 $$Author: wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2002-2004 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.

use strict;
use Test;
use Cwd;

BEGIN { plan tests => 5 }
BEGIN { require "t/test_utils.pl"; }

use P4::C4;
ok(1);

my $p4 = new P4::C4;
ok(1);

$p4->Init() or die "$0: %Error: Failed to connect to Perforce Server\n";
ok(1);

ok($p4->isUser($ENV{USER}||$ENV{P4USER}));
ok(!$p4->isUser("_a_name_that_doesnt_exist"));
