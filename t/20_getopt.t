#!/usr/local/bin/perl -w
# $Revision: 1.3 $$Date: 2002/07/24 15:32:53 $$Author: wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'make test' to test this package

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

