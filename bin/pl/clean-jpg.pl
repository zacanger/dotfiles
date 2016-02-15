#!/usr/bin/perl -w
my $help = <<_END_;
#
# File:         clean_jpg
#
# Description:  Remove EXIF and PhotoShop junk from JPG files or directories
#
# Syntax:       clean_jpg [OPTIONS] FILE/DIR [...]
#
# Options:      -a     - preserve all meta information except preview image
#               -d     - dummy mode (doesn't actually change the file)
#               -e     - preserve EXIF APP1 information
#               -o     - preserve other meta information (all but EXIF, XMP, PS)
#               -p     - preserve Photoshop APP13 information (includes IPTC)
#               -r     - recursively process sub-directories
#               -i DIR - ignore specified directory
#               -v     - verbose
#               -x     - preserve XMP APP1 information
#
# Revisions:    10/20/03 - PH Created
#               12/22/03 - PH Allow multiple filenames to be specified
#               12/24/03 - PH Added dummy mode.
#                          Remove all 0xe0-f markers (not just 0xe1,2,d,e,f)
#               01/21/04 - PH Added -e option
#               11/30/04 - PH Clean up unpack calls
#               01/31/05 - PH Remove multiple 0xff's in segment headers
#               04/09/05 - PH Changed -e option to -a, and added -e, -o, -p and
#                          -x options
#               04/15/05 - PH Fixed problem where specified information wasn't
#                          being preserved if entire directory is cleaned
#
_END_
#
# Legal:        Copyright (c) 2003-2005 Phil Harvey
#               You are free to use/modify this script for non-profit
#               purposes.  Not responsible for loss or damages.
#
#               Mail problems/comments to phil@owl.phy.queensu.ca
#
use strict;
require 5.002; 

sub CleanDir($;$);
sub CleanJpg($;$);

my @files;
my $recurse = 0;
my $verbose;
my $dummy;
my @ignore;
my $count = 0;
my $count_ok = 0;
my $count_dir = 0;
my $cleaned_bytes = 0;
my $preserve_flags = 0; # 1=exif, 2=xmp, 4=photoshop, 8=other

my $arg;
while ($arg = shift)
{
    if ($arg =~ /^-/) {
        for (my $i=1; ($_=substr $arg, $i, 1); ++$i) {
            /a/  and $preserve_flags |= 0xff, next;
            /d/  and $dummy = 1, next;
            /e/  and $preserve_flags |= 0x01, next;
            /i/  and push(@ignore,shift), next;
            /o/  and $preserve_flags |= 0x08, next;
            /p/  and $preserve_flags |= 0x04, next;
            /r/  and $recurse = 1, next;
            /v/  and $verbose = 1, next;
            /x/  and $preserve_flags |= 0x02, next;
            print "Unknown option $_\n";
            exit 1;
        }
    } else {
        push @files, $arg;
    }
}

unless (@files) {
    print $help;
    exit 1;
}

my $filename;
foreach $filename (@files) {
    if (-d $filename) {
        CleanDir($filename, $preserve_flags);
    } elsif (-e $filename) {
        my $result = CleanJpg($filename, $preserve_flags);
        if ($result > 1) {
            ++$count;
        } elsif ($result > 0) {
            ++$count_ok;
        }
    } else {
        die "Can't open $filename\n";
    }
}

if ($count or $count_ok or $count_dir>1) {
    printf("%5d directories scanned\n", $count_dir) if $count_dir > 1;
    printf("%5d JPG files cleaned\n", $count) if $count;
    printf("%5d JPG files already clean\n", $count_ok) if $count_ok;
    if ($cleaned_bytes >= 102400000) {
        printf("%5d MB saved\n", $cleaned_bytes / (1024*1024));
    } elsif ($cleaned_bytes >= 100000) {
        printf("%5d KB saved\n", $cleaned_bytes / 1024);
    } else {
        printf("%5d bytes saved\n", $cleaned_bytes);
    }
    print "But this was dummy mode, so nothing was changed\n" if $dummy;
} else {
    print "Nothing to do.\n";
}

sub CleanDir($;$)
{
    my $dir = shift;
    my $keep_flags = shift || 0;
    opendir(DIR_HANDLE, $dir) or die "Error opening directory $dir\n";
    my @file_list = readdir(DIR_HANDLE);
    closedir(DIR_HANDLE);
    
    ++$count_dir;
    
    my $file;
    foreach $file (@file_list) {
        my $path = "$dir/$file";
        if (-d $path) {
            next if $file =~ /^\./; # ignore dirs starting with "."
            next if grep /^$file$/, @ignore;
            $recurse and CleanDir($path, $keep_flags);
            next;
        }
        if ($file =~ /\.jpg$/i) {
            my $result = CleanJpg($path, $keep_flags);
            if ($result > 1) {
                ++$count;
            } elsif ($result > 0) {
                ++$count_ok;
            }
        }
    }
}

# rewrite a jpg file, removing EXIF data unless specified
# Inputs: 0) file name, 1) preserve flags (keep 1=exit, 2=xmp, 4=photoshop, 8=other)
# - returns 0 on error, 1 if nothing done, 2 if any junk was removed
# - also removes Canon preview image
sub CleanJpg($;$)
{
  my $infile = shift;
  my $keep_flags = shift || 0;
  my $outfile = '';
  my $success = 0;
  my $found_junk = 0;
  my ($s,$length,$buff);
  my ($ch,$data,$ord_ch);
  
  $verbose and print "File: $infile\n";
  
  open(JPG_IN,$infile) or return $success;
  binmode( JPG_IN );

  # create name of temporary file in same directory
  if ($infile =~ /(.*\/)/) {
    $outfile = $1;
  }
  $outfile .= "icat_CleanJpg.tmp";
  
  unless (open(JPG_OUT,">$outfile")) {
    close(JPG_IN);
    return $success;
  }
  binmode( JPG_OUT );
  
  # set input record separator to 0xff (the JPEG marker) to make reading quicker
  my $oldsep = $/;
  $/ = "\xff";

  if (read(JPG_IN,$s,2)==2 and $s eq "\xff\xd8" and print JPG_OUT $s) {
    # read file until we reach an end of image (EOI)
    Marker: for (;;) {
      # Find next marker (JPEG markers begin with 0xff)
      $data = <JPG_IN>;
      defined($data) or last;
      chomp $data;  # remove 0xff
      print JPG_OUT $data or last;
      # JPEG markers can be padded with unlimited 0xff's
      for (;;) {
        read(JPG_IN, $ch, 1) or last Marker;
        $ord_ch = ord($ch);
        last if $ord_ch != 0xff; # exit loop before printing marker
        ++$cleaned_bytes;
      }
      my $hdr = "\xff" . $ch;   # segment header
      # Now, $ord_ch is the value of the marker.
      if (($ord_ch >= 0xc0) && ($ord_ch <= 0xc3)) {
        # this is an image block
        read(JPG_IN, $buff, 7) == 7 or last;
        print JPG_OUT $hdr,$buff or last;
      # handle stand-alone markers 0x01 and 0xd0-0xd7
      # (and the non-marker 0x00, which follows an 0xff if it exists in data)
      } elsif ($ord_ch==0x00 or $ord_ch==0x01 or ($ord_ch>=0xd0 and $ord_ch<=0xd7)) {
        print JPG_OUT $hdr or last;
      } elsif ($ord_ch==0xd9) { # end of image (EOI)
        print JPG_OUT $hdr and $success = 1;
        my $curpos = tell(JPG_IN);
        seek(JPG_IN, 0, 2);    # seek to end of file
        my $preview_size = tell(JPG_IN) - $curpos;
        if ($preview_size) {
            $verbose and printf("  Removed preview image (%d bytes)\n", $preview_size);
            $found_junk = 1;
            $cleaned_bytes += $preview_size;
        }
        last;
      } else {
        # We **MUST** skip variables, since FF's within variable names are
        # NOT valid JPEG markers
        read(JPG_IN, $s, 2) == 2 or last;
        $length = unpack("n",$s);
        last if $length < 2;
        read(JPG_IN, $buff, $length-2) == $length-2 or last;
        # print out this field unless we are ignoring it
        my $remove;
        if ($ord_ch >= 0xe0 and $ord_ch <= 0xef) {
          if ($ord_ch==0xe1 and $buff=~/^Exif\0\0/) {
            # EXIF APP1 segment
            $remove = 1 unless $keep_flags & 0x01;
          } elsif ($ord_ch==0xe1 and $buff=~/^http:\/\/ns.adobe.com\/xap\/1.0\/\0/) {
            # XMP APP1 segment
            $remove = 1 unless $keep_flags & 0x02;
          } elsif ($ord_ch==0xed and $buff=~/^Photoshop 3.0\0/) {
            # Photoshop APP13 segment
            $remove = 1 unless $keep_flags & 0x04;
          } else {
            # Other application segment
            $remove = 1 unless $keep_flags & 0x08;
          }
        }
        if ($remove) {
          $verbose and printf("  Marker 0x%x: %5d bytes -- Cleaned\n", $ord_ch, $length);
          $found_junk = 1;
          $cleaned_bytes += $length + 2;
        } else {
          $verbose and printf("  Marker 0x%x: %5d bytes -- Kept\n", $ord_ch, $length);
          print JPG_OUT $hdr,$s,$buff or last;
        }
      }
    }
  }
  $/ = $oldsep;     # return separator to original value
  close(JPG_IN);
  close(JPG_OUT) or $success = 0;
  
  if ($success and $found_junk and not $dummy) {
    unless (rename($outfile,$infile)) {
      $success = 0;
      unlink($outfile);
    }
  } else {
    unlink($outfile);
  }
  $success or $found_junk = 0;

  return $success + $found_junk;
}


# end
