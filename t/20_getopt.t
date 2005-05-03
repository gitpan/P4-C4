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

BEGIN { plan tests => 5 }
BEGIN { require "t/test_utils.pl"; }

use P4::Getopt;
ok(1);

$P4::Getopt::Debug = 1;

my $opt = new P4::Getopt;
ok(1);

my @param = qw ( -c client
		 -d PWD
		 -p 1234
		 -P passwd
		 -s
		 -u daUser
		 -x t/20_getopt.opt
		 passthru
		 -c thispassedtoo
		 );

my @left = $opt->parameter(@param);
print "LEFT: ",join(" ",@left),"\n";
ok ($#left == 2);	# passthru

my @out = $opt->get_parameters();
print "OUT: ",(join(" ",@out)),"\n";
ok ($#out == 12);

my %hash = $opt->hashCmd("diff2", "-b", "brch", "frev", "frev2");
use Data::Dumper; print Dumper(\%hash);
ok ($hash{-b}
    && $hash{branch}[0] eq 'brch'
    && $hash{filerev}[0] eq 'frev'
    && $hash{filerev2}[0] eq 'frev2');

