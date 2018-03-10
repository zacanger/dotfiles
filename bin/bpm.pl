#!/usr/bin/perl
#
# bpm.pl - count newlines per minute
#
# Oona Räisänen 2012
# Public domain
#
# Usage: ./bpm [-n SAMPLES] [-p DECIMALS] [-s]
#
# -n SECONDS:  average over SECONDS seconds (default 5)
# -p DECIMALS: show DECIMALS decimal places (default 0)
# -s:          show seconds/beat instead of default beats/minute
#

use strict;
use warnings;
use Time::HiRes qw( time );
use Getopt::Std;

our %opts;
getopts('n:p:s', \%opts);

my $beat = 0;
my @times = ();

my $avtime = int($opts{'n'} // 5);
my $mode = (exists $opts{'s'} ? 1 : 0);
my $p = int($opts{'p'} // 0);

die 'n must be greater than 0' if ($avtime < 1);

while (<>) {
  key_press_event();
}

sub key_press_event {
  push @times, time;
  my $diff = $times[-1] - $times[0];

  if ($diff > 0) {
    if ($mode == 0) {
      printf q{%.} . $p . qq{f\n}, 60 / ($diff / $#times);
    } elsif ($mode == 1) {
      printf q{%.} . $p . qq{f\n}, $diff / $#times;
    }

    while ($times[-1] - $times[0] >= $avtime) {
      shift @times;
    }
  }
  $beat++;

  return;
}
