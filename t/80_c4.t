#!/usr/bin/perl -w
# $Revision: 1.5 $$Date: 2004/09/13 13:09:55 $$Author: ws150726 $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package
#
# Copyright 2002-2004 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.

use strict;
use Test;
use Cwd;

BEGIN { plan tests => 1 }
BEGIN { require "t/test_utils.pl"; }

run_system("${PERL} c4 info");
ok(1);
