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

$P4::C4::Debug = 1;

use P4::C4;
use P4::C4::Info;
ok(1);

my $p4 = new P4::C4;
ok(1);

$p4->Init() or die "$0: %Error: Failed to connect to Perforce Server\n";
ok(1);

if (!$ENV{P4CLIENT}) {
    warn "-NotRunning: No P4CLIENT setting\n";
    ok(1);
    ok(1);
    exit(0);
}

my @view = $p4->clientView();
ok(1);

#use Data::Dumper; print Dumper(\@view);
ok($view[0][0]);
