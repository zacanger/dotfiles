#!/usr/bin/perl5
#
#     IMAGES.CGI
#          by Matt Kruse (mkruse@saunix.sau.edu)
#          8/20/95
#
#     images.cgi is a simple script that will create an HTML index of all
# images in the current directory and write it out to images.html
#     The page contains the images, links to the images themselves, their
# names, and their sizes.
#
#     USAGE: images.cgi <filenames>
#  examples: images.cgi *.gif
#            images.cgi *.gif *.jpg
#            images.cgi a.gif b.gif c.gif d.gif
#
$DIR=`pwd`;

open(HTML,"> images.html");
print HTML <<EOF;
<HTML>
<HEAD>  <TITLE>Image Index</TITLE>  </HEAD>
<BODY>
<H1 ALIGN=CENTER>Image Index</H1>
The following images are in the directory: <B>$DIR</B><P>
<HR>
EOF

foreach (@ARGV) {
 print STDOUT "Adding $_ ...\n";
 $SIZE=(-s $_);
 print HTML "<A HREF=\"$_\">\n";
 print HTML "<IMG SRC=\"$_\" BORDER=\0 ALT=\"[ $_ ]\"></A>\n";
 print HTML "  <B>$_</B> <I>($SIZE bytes)</I><P>\n";
 }

print HTML "<HR>\n</BODY>\n</HTML>\n";
close(HTML);

print STDOUT "Done.\n\n";
