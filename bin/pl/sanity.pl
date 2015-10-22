#!/usr/bin/perl -w

use File::Basename;
use Getopt::Std;

# check for unicodedecoder
my $unidec = 0;
eval { require Text::Unidecode; };
unless ($@) {
  $unidec = 1;
  Text::Unidecode ->import();
}else{
}

# check commandline params
my %OPTS;
getopts('lea',\%OPTS);

# Function prototypes:
sub readFiles($);
sub renameFile($$);
sub help();

##############################################################################
# rename a given File
sub renameFile($$){

  (my $path,$file) = @_;
  my $newfile = $file;

  #remove chars below 32
  $newfile =~ s/[\x00-\x1f]/_/g;

  #urldecode:
  $newfile =~ s/%([0-9A-Fa-f][0-9A-Fa-f])/chr(hex($1))/ge;

  #fix broken unicode chars for german umlauts
  $newfile =~ s/\303\204/Ae/g;
  $newfile =~ s/\303\226/Oe/g;
  $newfile =~ s/\303\234/Ue/g;
  $newfile =~ s/\303\244/ae/g;
  $newfile =~ s/\303\266/oe/g;
  $newfile =~ s/\303\274/ue/g;
  $newfile =~ s/\303\237/ss/g;

  #convert to latin1
  if($unidec){
    $newfile = unidecode($newfile);
  }

  #add more translations here:
  
  $newfile =~ s/\\//g;     #remove backspaces
  $newfile =~ s/\*/x/g;    #windows doesn't like this at all :-)
  $newfile =~ s/&/_and_/g; #ampersand to english
  $newfile =~ s/@/_at_/g;
  $newfile =~ s/['"`]//g;  #remove these completely

  #lowercase some known extensions  
  $newfile =~ s/bat$/bat/gi;
  $newfile =~ s/exe$/exe/gi;
  $newfile =~ s/ogg$/ogg/gi;
  $newfile =~ s/mp3$/mp3/gi;
  $newfile =~ s/rar$/rar/gi;
  $newfile =~ s/pdf$/pdf/gi;
  $newfile =~ s/pdb$/pdb/gi;
  
  #German Umlauts (Linux charset)
  $newfile =~ s/�/ue/g;
  $newfile =~ s/�/Ue/g;
  $newfile =~ s/�/oe/g;
  $newfile =~ s/�/Oe/g;
  $newfile =~ s/�/ae/g;
  $newfile =~ s/�/Ae/g;
  $newfile =~ s/�/ss/g;

  #German Umlauts (Windows charset)
  $newfile =~ s/\x8e/Ae/g;
  $newfile =~ s/\x99/Oe/g;
  $newfile =~ s/\x9A/Ue/g;
  $newfile =~ s/\x84/ae/g;
  $newfile =~ s/\x94/oe/g;
  $newfile =~ s/\x81/ue/g;
  $newfile =~ s/\xe1/ss/g;
  $newfile =~ s/\253/.5/g;

  #Accents
  $newfile =~ s/�/e/g;
  $newfile =~ s/�/E/g;
  $newfile =~ s/�/e/g;
  $newfile =~ s/�/a/g;
  $newfile =~ s/�/a/g;
  $newfile =~ s/�/o/g;
  $newfile =~ s/�/n/g;

  $newfile =~ s/\202/_/g;
  $newfile =~ s/\212/_/g;

  $newfile =~ s/_\././g;
  $newfile =~ s/\.\././g;
  $newfile =~ s/\357/'/g;

  #Remove all chars we don't want
  if($OPTS{'e'}){
    $newfile =~ s/[^A-Za-z_0-9\.\-]/_/g;
  }else{
    $newfile =~ s/[^A-Za-z_0-9\(\)\[\]\.\-]/_/g;
  }

  #some cleanup
  $newfile =~ s/_-_/-/g;   #Dashes should not be surounded by underscores
  $newfile =~ s/_-/-/g;
  $newfile =~ s/-_/-/g;
  $newfile =~ s/__+/_/g;    #Reduce multiple spaces to one

  #lowercase if wanted
  $newfile = lc($newfile) if($OPTS{'l'});

  if ("$path/$file" ne "$path/$newfile"){
    print STDERR "Renaming '$file' to '$newfile'";
    if (-e "$path/$newfile"){
            print STDERR "\tSKIPPED new file exists\n";
    }else{
       if (rename("$path/$file","$path/$newfile")){
        print STDERR "\tOKAY\n";
      }else{
        print STDERR "\tFAILED\n";
      }
          }
  }
}

##############################################################################
# Read a given directory and its subdirectories
sub readFiles($) {
  (my $path)=@_;
  
  opendir(ROOT, $path);
  my @files = readdir(ROOT);
  closedir(ROOT);

  foreach (@files) {
    next if /^(\.|\.\.)$/;             #skip upper dirs
    next if((/^\./) && (!$OPTS{'a'})); #skip hidden files
    my $file =$_;
    my $fullFilename    = "$path/$file";
    
    
    if (-d $fullFilename) {
      readFiles($fullFilename); #Recursion
    }
    
    renameFile($path,$file); #Rename

  }
}

##############################################################################
# prints a short Help text
sub help() {
print <<STOP

      Syntax: sanity.pl [options] <file(s)>

      This tool renames files back to sane names. It does so by replacing
      spaces, german umlauts and some special chars by underscores.

      If a renamed version of a file already exists the renaming will be
      skipped.

      Options:

        -l convert to lowercase
        -e extended cleaning (removes brackets as well)
        -a convert all files - don't exclude hidden files and dirs

      The argument can be files and directories. WARNING: Directories will
      be recurseively changed.
      _____________________________________________________________________
      sanity.pl - Sanitize Filenames
      Copyright (C) 2003-2005 Andreas Gohr <andi\@splitbrain.org>

      This program is free software; you can redistribute it and/or
      modify it under the terms of the GNU General Public License as
      published by the Free Software Foundation; either version 2 of
      the License, or (at your option) any later version.
      
      See COPYING for details
STOP
}

##############################################################################
# Main

if (@ARGV < 1){
  &help();
  exit -1;
}

foreach my $arg (@ARGV){
  if(-d $arg){
    &readFiles($arg);
  }else{
    &renameFile(dirname($arg),basename($arg));  
  }
}