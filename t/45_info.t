#!/usr/local/bin/perl -w
# $Revision: 1.2 $$Date: 2002/07/24 15:32:53 $$Author: wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package

use strict;
use Test;
use Cwd;

BEGIN { plan tests => 4 }
BEGIN { require "t/test_utils.pl"; }

$P4::C4::Debug = 1;

use P4::C4;
use P4::C4::Info;
ok(1);

my $p4 = new P4::C4;
ok(1);

$p4->Init() or die "$0: %Error: Failed to connect to Perforce Server\n";
ok(1);

ok($p4->serverVersion());


