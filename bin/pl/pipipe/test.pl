#!/usr/bin/perl -w
# Test suite for pip.
# Copyright 2002 Ed Avis, see the file COPYING.
#

use strict;

my $PIP = 'blib/script/pip';
if (not -x $PIP) {
    die "$PIP not executable\n";
}

# Perl programs used as the command run by pip.
my $check_arg_content # (strange bug where 'chomp $c' doesn't work)
  = 'open(FH, $ARGV[0]) or die; undef $/; $c = <FH>; $c =~ s/\n$//; if ($c eq $ARGV[1]) { print "same\n" } else { print "diff\n" }; foreach (@ARGV[2..$#ARGV]) { open(FH, ">$_") or die }';
my $check_same
  = 'undef $/; foreach (@ARGV) { open(FH, $_) or die; $c = <FH>; if (defined $last and $c ne $last) { print "diff"; exit 1 } $last = $c }; print "same"';
my $lower = 'while (<STDIN>) { print lc }';
my $lower_fromto
  = 'open(IN, $ARGV[0]) or die; open(OUT, ">$ARGV[1]") or die; while (<IN>) { print OUT lc }';
my $lower_modify
  = 'open(IN, $ARGV[0]) or die; undef $/; $_ = <IN>; open(OUT, ">$ARGV[0]") or die; print OUT lc';
my $tee
  = 'undef $/; $i = <STDIN>; foreach (@ARGV) { open (OUT, ">$_") or die; print OUT $i }';
my $tee_from
  = 'open(IN, shift @ARGV) or die; undef $/; $i = <IN>; foreach (@ARGV) { open(OUT, ">$_") or die; print OUT $i }';
my $check_ext
  = 'while (@ARGV) { ($e, $f, @ARGV) = @ARGV; if ($f !~ /\Q$e\E$/) { print "$f has not extn $e"; exit 1 } }; print "same"';
my $print_args = 'print join(",", @ARGV)';
my $stdin_plain = 'if (-f STDIN) { print "yes" } else { print "no" }';
my $stdout_plain = 'if (-f STDOUT) { print "yes" } else { print "no" }';
my $arg_eq = 'for (shift @ARGV) { /^(\d+)(.*)/ or die; ($n, $v) = ($1, $2) } if ($ARGV[$n] eq $v) { print "same" } else { print "diff" }';
my $print_many = 'print "stdout"; foreach (@ARGV) { open FH, ">$_" or die; print FH $i++ }';

# Tests are: -io flags to pip, perl command to run, args to perl
# command (including placeholders), standard input fed to pip,
# expected output from pip.
#
my @tests
  = (
     # Basic function of -i.
     [ [ '-i' ], $check_arg_content, [ '-', 'foo' ], 'foo', 'same' ],
     [ [ '-i' ], $check_arg_content, [ '-.x', 'foo' ], 'foo', 'same' ],

     # Check that -o and -b don't interfere.
     [ [ qw(-i -o) ], $check_arg_content, [ '-.x', 'foo', '-' ], 'foo', 'same' ],
     [ [ '-ib' ], $check_arg_content, [ '-.x', 'foo', '-' ], 'foo', 'same' ],

     # Multiple input files.
     [ [ '-ii' ], $check_same, [ '-', '-.ext' ], 'foo', 'same' ],
     [ [ '-bi' ], $check_same, [ '-', '-' ], 'foo', 'samefoo' ], # concatenated

     # Input and output in separate files.
     [ [ '-io' ], $lower_fromto, [ '-', '-' ], 'BLAH', 'blah' ],
     [ [ '-io' ], $lower_fromto, [ '-.in', '-.out' ], 'BLAH', 'blah' ],
     [ [ '-ib' ], $lower_fromto, [ '-.in', '-.out' ], 'BLAH', 'blah' ],

     # Input and output in the same file.
     [ [ '-b' ], $lower_modify, [ '-' ], 'BLAH', 'blah' ],

     # Multiple output files.
     [ [ '-i' ], $tee_from, [ '-' ], 'frou', '' ],
     [ [ '-i', '-o' ], $tee_from, [ '-', '-' ], 'frou', 'frou' ],
     [ [ '-i', '-b', '-o' ], $tee_from, [ '-', '-', '-' ], 'frou', 'froufrou' ],

     # Temporary files with a given extension.
     [ [ '-i' ], $check_ext, [ '.foo', '-.foo' ], '', 'same' ],

     # Without -i or -b the input should be unchanged.
     [ [], $tee, [ '-' ], 'foo', 'foo' ],       # Perl handles - itself
     [ [ '-o' ], $tee, [ '-' ], 'foo', 'foo' ],

     # Without placeholders the arguments should be unchanged.
     [ [], $print_args, [ qw(hello --there -x .42) ], '', 'hello,--there,-x,.42' ],

     # Tests for -I and its interaction with -i.
     [ [ '-I' ], $check_arg_content, [ '-', 'foo' ], 'foo', 'same' ],
     [ [ '-Ii' ], $check_same, [ '-', '-' ], 'foo', 'same' ],
     [ [ '-Ii' ], $arg_eq, [ '1-', '-', '-' ], '', 'same' ],
     [ [ '-I' ], $stdin_plain, [], '', 'yes' ],

     # Test -O and its interaction with -o.
     [ [ '-O' ], $lower, [], 'BLAH', 'blah' ],
     [ [ '-Ooo' ], $print_many, [ '-', '-' ], '', 'stdout01' ],
     [ [ '-O' ], $arg_eq, [ '0-', '-' ], '', 'same' ],
     [ [ '-O' ], $stdout_plain, [], '', 'yes' ],

     # Test the test suite.
     [ [ '-i' ], $check_arg_content, [ '-.x', 'foo' ], 'bar', 'diff' ],
     [ [], $check_same, [], '', 'same' ],
     [ [], $check_same, [ qw(test.pl test.pl) ], '', 'same' ],
     [ [], $check_same, [ qw(test.pl Makefile.PL) ], '', 'diff' ],
     [ [], $print_args, [ qw(a b c) ], '', 'a,b,c' ],
     [ [], $stdin_plain, [], '', 'no' ],
     [ [], $stdout_plain, [], '', 'no' ],
    );

print '1..', scalar @tests, "\n";
my $test_num = 1;
foreach (@tests) {
    my ($pip_args, $prog, $prog_args, $in, $expect) = @$_;

    my $inf = 'test.in';
    my $outf = 'test.out';
    open(IN, ">$inf") or die "cannot write to $inf: $!";
    print IN $in or die "cannot write to $inf: $!";
    close IN or die "cannot close $inf: $!";
    local *OLDIN;
    open(OLDIN, '<&STDIN') or die "cannot dup stdin: $!";
    open(STDIN, "cat <$inf |") or die "cannot open cat from $inf: $!";
    local *OLDOUT;
    open(OLDOUT, '>&STDOUT') or die "cannot dup stdout: $!";
    open(STDOUT, "| cat >$outf") or die "cannot open cat to $outf: $!";

    my @cmd = ($PIP, @$pip_args, 'perl', '-e', $prog, @$prog_args);
    my $result = system(@cmd);

    close(STDOUT) or die "cannot close $outf: $!";
    open(STDOUT, '>&OLDOUT') or die "cannot dup stdout back again: $!";
    close(STDIN) or die "cannot close $inf: $!";
    open(STDIN, '<&OLDIN') or die "cannot dup stdin back again: $!";

    if ($result) {
	my ($status, $sig, $core) = ($? >> 8, $? & 127, $? & 128);
	if ($sig) {
	    die "@cmd killed by signal $sig, aborting";
	}
	elsif ($status) {
	    print "not ok $test_num\n";
	    print STDERR "failed test: " . join(' ', @cmd) . "\n";
	    print STDERR "exited with status $status\n";
	}
	elsif ($core) {
	    print "not ok $test_num\n";
	    print STDERR "failed test: " . join(' ', @cmd) . "\n";
	    print STDERR "dumped core\n";
	}
	else { die }
    }
    else {
	# Exit status okay, check output.
	open(GOT, $outf) or die "cannot open $outf: $!";
	my $got;
	{
	    local $/ = undef;
	    $got = <GOT>;
	}
	close GOT or die "cannot close $outf: $!";

	$got =~ s/\n+$//;
	if ($got ne $expect) {
	    print "not ok $test_num\n";
	    print STDERR "failed test: " . join(' ', @cmd) . "\n";
	    print "input: $in\n";
	    print "expected output: $expect\n";
	    print "got output: $got\n";
	} else {
	    print "ok $test_num\n";
	}
    }

    foreach ($inf, $outf) {
	unlink or die "cannot unlink $_: $!";
    }
    ++ $test_num;
}
