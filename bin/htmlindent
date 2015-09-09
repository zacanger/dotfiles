#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use HTML::TreeBuilder;

my $path = shift;
my $body = '';

if ($path) {
  open my $fh, '<', $path or die $!;
  $body .= $_ while <$fh>;
  close $fh;
} else {
  $body .= $_ while <>;
}

my $tree = HTML::TreeBuilder->new;
$tree->parse($body);

print $tree->as_HTML('<>&', "  ", {});