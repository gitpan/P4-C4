# $Id: Makefile.PL,v 1.4 2002/08/08 13:35:37 wsnyder Exp $
# DESCRIPTION: Perl ExtUtils: Type 'perl Makefile.PL' to create a Makefile for this package

require 5.005;
use ExtUtils::MakeMaker;
use Carp;

sub MY::postamble {
"
install-here::
	make INSTALLMAN1DIR=/usr/local/man/man1 INSTALLMAN3DIR=/usr/local/man/man3 INSTALLBIN=/usr/local/bin INSTALLSCRIPT=/usr/local/bin install

README: readme.texi
	-rm \$@
	makeinfo \$< --output \$@ --no-headers --no-validate

## Maintainer use:
tag:
	cvs tag -F \$(DISTNAME)_\$(VERSION_SYM) .

maintainer-dist: dist tag
	cp \$(DISTVNAME).tar.gz \$(HOME)/src/kits
	mv \$(DISTVNAME).tar.gz \$(HOME)/backpack

maintainer-clean: distclean
	-rm README Makefile

dist: distcheck
";
}

## Remember to upgrade version number!
WriteMakefile(
	      DISTNAME	=> 'P4-C4',
	      NAME	=> 'P4::C4',
	      AUTHOR	=> 'Wilson Snyder <wsnyder@wsnyder.org>',
	      ABSTRACT_FROM => 'C4.pm',
	      VERSION_FROM  => 'C4.pm',
	      PREREQ_PM => {'P4::Client' => 1.1980,
			},
	      EXE_FILES	=> [qw( c4 )],
	      'clean'	=> {FILES => 'test_store', },
	      'dist'	=> {COMPRESS => 'gzip -9f',
			    SUFFIX   => '.gz', 
			    DIST_DEFAULT => 'README all tardist',
			},
	      );
