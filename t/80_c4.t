#!/usr/local/bin/perl -w
# $Revision: 1.1 $$Date: 2002/07/24 20:00:27 $$Author: wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package

use strict;
use Test;
use Cwd;

BEGIN { plan tests => 1 }
BEGIN { require "t/test_utils.pl"; }

run_system("./c4 info");
ok(1);
