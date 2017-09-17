#!/usr/bin/perl

## generate wordlist from input file
# (c) 2012 F00L.DE

## check for arguments
# 1 - FILENAME
if (!defined $ARGV[1]) {
  print "Usage: $0 <inputfile> <outputfile>\n";
  exit(1);
}

## init vars
$inputfile = $ARGV[0];
$outputfile = $ARGV[1];

# open files
open(INPUT, $inputfile);
open(OUTPUT, ">$outputfile");

# loop lines of input file
foreach $line (<INPUT>) {

  # split words by -space-
  @words = split(/ /, $line);
  foreach $word (@words) {

    # removing punctuation characters could be useful (this depends on input text!!)
    $word =~ s/[,.!?]$//g;

    print OUTPUT lc $word . "\n"; # convert words to lowercase
  }
}

# close files
close(HTML);
close(WORDLIST);

# unique sort the file
system("sort -u \"$outputfile\" -o \"$outputfile\"");

