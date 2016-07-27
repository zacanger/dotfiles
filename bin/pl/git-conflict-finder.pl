#!/usr/bin/env perl
# Find conflict markers in files
# 2013, Zeger Van de Vannet

use Term::ANSIColor;

my $files = `git ls-files`;

my @files = split "\n", $files;

for $file (@files) {
  open FILE, "$file" or die $!;
  my @lines = <FILE>;
  for $i (keys @lines) {
    if ($lines[$i] =~ /\<{3,}/) {
      $linenr = $i + 1;
      print color("blue"), "$file", color("reset");
      print ":";
      print color("yellow"), "$linenr ", color("reset");
      print "$lines[$i]";
    }
  }
  close FILE;
}
