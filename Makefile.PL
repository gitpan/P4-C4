# $Id: Makefile.PL 709 2005-05-03 21:32:07Z wsnyder $
# DESCRIPTION: Perl ExtUtils: Type 'perl Makefile.PL' to create a Makefile for this package
#
# Copyright 2002-2005 by Wilson Snyder.  This program is free software;
# you can redistribute it and/or modify it under the terms of either the GNU
# General Public License or the Perl Artistic License.

require 5.005;
use ExtUtils::MakeMaker;
use Carp;

sub MY::postamble {
"
install-here::
	make install

README: readme.texi
	-rm -rf \$@
	makeinfo \$< --output \$@ --no-headers --no-validate

## Maintainer use:
preexist:
	test ! -r \$(HOME)/src/kits/\$(DISTVNAME).tar.gz

tag:
	svnorcvs tag  \$(DISTNAME)_\$(VERSION_SYM)

maintainer-diff:
	svnorcvs diff \$(DISTNAME)_\$(VERSION_SYM) 

maintainer-dist: preexist dist tag
	cp \$(DISTVNAME).tar.gz \$(HOME)/src/kits
	mv \$(DISTVNAME).tar.gz \$(HOME)/backpack

maintainer-clean: distclean
	-rm -rf README Makefile

dist: distcheck
";
}

## Remember to upgrade version number!
WriteMakefile(
	      DISTNAME	=> 'P4-C4',
	      NAME	=> 'P4::C4',
	      AUTHOR	=> 'Wilson Snyder <wsnyder@wsnyder.org>',
	      ABSTRACT_FROM => 'lib/P4/C4.pm',
	      VERSION_FROM  => 'lib/P4/C4.pm',
	      NO_META	=> 1,
	      PREREQ_PM => {'P4::Client' => 2.2279,
			},
	      EXE_FILES	=> [qw( c4 c4_job_edit )],
	      'clean'	=> {FILES => 'test_store', },
	      'dist'	=> {COMPRESS => 'gzip -9f',
			    SUFFIX   => '.gz', 
			    DIST_DEFAULT => 'README all tardist',
			},
	      );

