#!/usr/bin/perl

 #     # #     # #     #  #####  ######     #    ######
 #  #  # #  #  # #  #  # #     # #     #   # #   #     #
 #  #  # #  #  # #  #  # #       #     #  #   #  #     #
 #  #  # #  #  # #  #  # #  #### ######  #     # ######
 #  #  # #  #  # #  #  # #     # #   #   ####### #     #
 #  #  # #  #  # #  #  # #     # #    #  #     # #     #
  ## ##   ## ##   ## ##   #####  #     # #     # ######

#########################################################
#                 A WWW http grabber.                   #
# Basically, given an http address it will get you      #
# the resource.                                         #
#                                                       #
# Usage:  wwwgrab http://site.name.edu/ [filename]      #
#                                                       #
# ex.  wwwgrab http://www.engr.wisc.edu/~ballard/       #
# will get you the source behind my homepage and        #
# wwwgrab http://www.engr.wisc.edu/~ballard/pics/me.gif #
# will get you a .gif image of my picture.              #
#                                                       #
#########################################################
# Written by Jeff Ballard (ballard@cae.wisc.edu) 7/2/95 #
#              URL:  http://www.engr.wisc.edu/~ballard/ #
#########################################################
#                                                       #
# Feel free to contact me with any questions/comments/  #
#  and such.                                            #
#                                                       #
#########################################################
# This program is freeware.  *NO* warranty is expressed,#
# implied, nor granted to you in any way.  Use of this  #
# program is at your own risk.  Your milage may vary.   #
# This progarm was packed by weight, not by volume.     #
# Some settling may have occurred during shipment.      #
#########################################################
# Much thanks to Brendan Kehoe <brendan@cygnus.com>     #
# URL: http://www.zen.org/~brendan/                     #
# for his help in getting rid of the constants          #
#########################################################

# Required for perl5.
use Socket;

# Given an http address, rip it into its coresponding parts.

($_, $savefilename) = @ARGV;

if (!$_) {
  print "Usage:  $0 http://www.any.site/location [outputfilename]\n";
  print "  Where [outputfilename] is the optional filename to create.\n";
  print "  (ommitting this means that it will mean that the data will be\n";
  die "  sent to STDOUT.  If this file exists, it will be overwritten)\n";
}

/http:\/\/([^\/]*)\/*([^ ]*)/;
$site = $1;
$file = "/".$2;

if (!$site) {
  die "$0:  Fatal Error.  You appear to have munged your URL address.\nIt must be in the form of http://www.any.site/location\n";
}

$_ = $site;
/^([^:]*):*([^ ]*)/;
$site = $1;
$port = $2;
$port = 80 unless $port;

$hostname = $site;

#print STDERR "[$site] [$port] [$file]\n";

# Open a socket and get the data
  ($sockaddr,$there,$response,$tries) = ("Snc4x8");
  $there = pack($sockaddr,2,$port, &getaddress($hostname));
  ($a, $b, $c, $d) = unpack('C4', $hostaddr);

  $proto = (getprotobyname ('tcp'))[2];

  if (!socket(S,AF_INET,SOCK_STREAM,$proto)) { die "$0:  Fatal Error.  $!\n"; }
  if (!connect(S,$there)) { die "$0:  Fatal Error.  $!\n"; }
  select(S);$|=1;
  select(STDOUT);
  print S "GET $file\r\n";
  if ($savefilename) {
    open(OUT,">".$savefilename) || die "$0: Fatal error.  Cannot create $savefilename.\n";
  }
  while($line = <S>) {
    if ($savefilename) {
      print OUT $line;
    } else {
      print $line;
    }
  }
  close(S);
  if ($savefilename) {
    close(OUT);
  }


sub getaddress {
  local($host) = @_;
  local(@ary);
  @ary = gethostbyname($host);
  return(unpack("C4",$ary[4]));
}

