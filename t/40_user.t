#!/usr/local/bin/perl -w
# $Revision: 1.2 $$Date: 2002/07/23 14:56:31 $$Author: wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package

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
