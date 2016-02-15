#!/usr/bin/perl

## frequency analzysis tool for simple crypto stuff
# (c) 2012 F00L.DE 

## check for arguments
# 1 - FILENAME
if (!defined $ARGV[0]) {
  print "Usage: $0 <filename>\n";
  exit(1);
}

## init vars
%chars = ();
$filename = $ARGV[0];
$count = 0;

## loop over all lines of file and count chars
open(FILE, $filename);
foreach $line (<FILE>) {
  for ($i=0;$i<length($line);$i++) {
    $char = substr($line, $i, 1); 	# LOWERCASE ONLY(!!)

    # filter special chars
    $char =~ s/ /<SPACE>/gm;
    $char =~ s/\t/<TAB>/gm;
    $char =~ s/\n/<CR>/gm;

    # just count ascii chars
    if ((ord($char) >= 97) && (ord($char) <= 122)) { $count++; }

    if ($chars{$char}) { $chars{$char} += 1; } else { $chars{$char} = 1; }
  }
}
close(FILE);

## output result
foreach $char (sort { $chars{$b} <=> $chars{$a} } keys %chars) {	# sort by occurence
  if (((ord($char) >= 97) && (ord($char) <= 122)) || ((ord($char) >= 65) && (ord($char) <= 90))) {
    printf("%10s = %5d ( %.2f \% )\n", $char, $chars{$char}, ($chars{$char}/$count*100));
  } else {
    printf("%10s = %5d\n", $char, $chars{$char});
  }
}
