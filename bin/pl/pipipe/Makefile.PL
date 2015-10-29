# Makefile.PL - run this to generate a Makefile for pip.
# Copyright 2002 Ed Avis.  See COPYING for conditions.
#
use ExtUtils::MakeMaker;

# Work around a bug installing section 1 manpages.
use vars '%extra_constants';
%extra_constants = (INSTALLMAN1DIR  => '$(PREFIX)/man/man1');

my $VERSION = '1.2';

WriteMakefile
  (
   NAME	     => 'pip',
   VERSION   => $VERSION,
   ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
    (AUTHOR  => 'Ed Avis <ed@membled.com>') : ()),
   EXE_FILES => [ qw(pip pip_tex pip_latex pip_latex2html) ],
   PL_FILES  => { 'pip.PL' => 'pip' },
   PREREQ_PM => { 'File::Temp' => 0 },
  );

# 'make clean' doesn't remove generated files from *.PL (see posting
# to makemaker@perl.org).  Fix it.
#
sub MY::clean {
    package MY;
    my $inherited = shift->SUPER::clean(@_);
    $inherited =~ s/\s+$//;
    $inherited .= "\n\t-rm -f pip\n";
    return $inherited;
}

sub MY::processPL {
    package MY;
    my $inherited = shift->SUPER::processPL(@_);

    # Creating pip depends on pip.in (as well as pip.PL).
    $inherited =~ s!^(\s*pip\s+::\s.+)!$1 pip.in!m
      or die "no pip in: $inherited";

    return $inherited;
}

sub MY::constants {
    package MY;
    my $inherited = shift->SUPER::constants(@_);
    die if not keys %::extra_constants;
    foreach (sort keys %::extra_constants) {
	$inherited .= "$_ = $::extra_constants{$_}\n";
    }
    return $inherited;
}
