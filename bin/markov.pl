#!/usr/bin/perl
#
# Markov text generator
#
# (c) windytan
# MIT license
#

use strict;
use warnings;
use English;
use v5.10;

my %dict;
my %is_original;
my %is_beginning;
my @beginnings;

main();

sub print_usage {
  say "Usage: perl $0 FILE [NUM]";
}

sub main {

  if (@ARGV == 0) {
    print_usage();
    exit;
  }

  my $filename = shift @ARGV;
  my $num_chains = ($ARGV[0] // 10);

  make_dict($filename);

  for (1 .. $num_chains) {
    say make_chain();
  }

  return;

}

sub make_dict {

  my $filename = shift;
  open my $fh, '<', $filename or die $filename . ": " . $OS_ERROR;
  my @lines = <$fh>;
  close $fh;

  for (@lines) {

    chomp;
    s/([\,\.\!\?\:])/ $1/g;
    $is_original{$_} = 1;
    my @words = split / +/;

    for my $first (0 .. $#words-2) {
      my $dict_first  = $words[$first] . q{ } . $words[$first + 1];
      my $dict_second = $words[$first + 2];
      push @{$dict{$dict_first}}, $dict_second;
      if ($first == 0) {
        $is_beginning{$dict_first} ++;
      }
    }

  }

  @beginnings = keys %is_beginning;

  return;

}

sub make_chain {

  my $joined = q{};

  while (1) {
    my @chain = split / /, $beginnings[rand @beginnings];

    while (1) {
      my $pair = $chain[-2] . q{ } . $chain[-1];
      last if (not exists $dict{$pair});
      my @alts = @{$dict{$pair}};
      push @chain, $alts[rand @alts];
    }

    $joined = join q{ }, @chain;
    last if (not exists $is_original{$joined});
  }

  $joined =~ s/ ([\.\,\!\?\:])/$1/g;

  return $joined;

}
