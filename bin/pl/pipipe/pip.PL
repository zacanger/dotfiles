#!/usr/bin/perl -w
#
# Generate pip from pip.in.  This is to include the section about
# /dev/stdin and /dev/stdout only on systems that have those devices.
#
# Copyright 2002 Ed Avis, see the file COPYING.
#
use strict;
use IO::File;
my $out = shift @ARGV; die "no output file given" if not defined $out;
my $in = 'pip.in';
my $out_fh = new IO::File "> $out" or die "cannot write to $out: $!";
my $in_fh = new IO::File "< $in" or die "cannot read $in: $!";
my $seen_dev_stdin = 0;
while (<$in_fh>) {
    if (/^\@BEGIN_DEV_STDIN\s*$/) {
	warn "$in:$.: seen \@BEGIN_DEV_STDIN line before\n"
	  if $seen_dev_stdin++;
	# On Linux these two files appear to be pipes, not devices,
	# but I won't assume that's the case on other OSes.  Just test
	# with -e.
	#
	my $hin = -e '/dev/stdin';
	my $hout = -e '/dev/stdout';
	my $incl;
	if (not $hin and not $hout) {
	    $incl = 0;
	}
	elsif (not $hin and $hout) {
	    die 'found /dev/stdin but not /dev/stdout';
	}
	elsif ($hin and not $hout) {
	    die 'found /dev/stdout but not /dev/stdin';
	}
	elsif ($hin and $hout) {
	    $incl = 1;
	}
	else { die }

	while (<$in_fh>) {
	    last if /^\@END_DEV_STDIN\s*$/;
	    print $out_fh $_ if $incl;
	}
    }
    else {
	print $out_fh $_;
    }
}

close $out_fh or die "cannot close $out: $!";
close $in_fh or die "cannot close $in: $!";

warn "$in: did not see \@BEGIN_DEV_STDIN section to substitute\n"
  if not $seen_dev_stdin;

