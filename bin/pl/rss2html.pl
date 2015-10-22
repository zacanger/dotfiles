#!/usr/bin/perl -w
# rss2html - converts an RSS file to HTML
# It take one argument, either a file on the local system,
# or an HTTP URL like http://slashdot.org/slashdot.rdf
# by Jonathan Eisenzopf. v1.0 19990901
# Copyright (c) 1999 Jupitermedia Corp. All Rights Reserved.
# See http://www.webreference.com/perl for more information
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# INCLUDES
use strict;
use XML::RSS;
use LWP::Simple;

# Declare variables
my $content;
my $file;

# MAIN
# check for command-line argument
die "Usage: rss2html.pl (<RSS file> | <URL>)\n" unless @ARGV == 1;

# get the command-line argument
my $arg = shift;

# create new instance of XML::RSS
my $rss = new XML::RSS;

# argument is a URL
if ($arg=~ /http:/i) {
    $content = get($arg);
    die "Could not retrieve $arg" unless $content;
    # parse the RSS content
    $rss->parse($content);

# argument is a file
} else {
    $file = $arg;
    die "File \"$file\" does't exist.\n" unless -e $file;
    # parse the RSS file
    $rss->parsefile($file);
}

# print the HTML channel
&print_html($rss);

# SUBROUTINES
sub print_html {
    my $rss = shift;
    print <<HTML;
<table bgcolor="#000000" border="0" width="200"><tr><td>
<TABLE CELLSPACING="1" CELLPADDING="4" BGCOLOR="#FFFFFF" BORDER=0 width="100%">
  <tr>
  <td valign="middle" align="center" bgcolor="#EEEEEE"><font color="#000000" face="Arial,Helvetica"><B><a href="$rss->{'channel'}->{'link'}">$rss->{'channel'}->{'title'}</a></B></font></td></tr>
<tr><td>
HTML

    # print channel image
    if ($rss->{'image'}->{'link'}) {
	print <<HTML;
<center>
<p><a href="$rss->{'image'}->{'link'}"><img src="$rss->{'image'}->{'url'}" alt="$rss->{'image'}->{'title'}" border="0"
HTML
        print " width=\"$rss->{'image'}->{'width'}\""
	    if $rss->{'image'}->{'width'};
	print " height=\"$rss->{'image'}->{'height'}\""
	    if $rss->{'image'}->{'height'};
	print "></a></center><p>\n";
    }

    # print the channel items
    foreach my $item (@{$rss->{'items'}}) {
	next unless defined($item->{'title'}) && defined($item->{'link'});
	print "<li><a href=\"$item->{'link'}\">$item->{'title'}</a><BR>\n";
    }

    # if there's a textinput element
    if ($rss->{'textinput'}->{'title'}) {
	print <<HTML;
<form method="get" action="$rss->{'textinput'}->{'link'}">
$rss->{'textinput'}->{'description'}<BR> 
<input type="text" name="$rss->{'textinput'}->{'name'}"><BR>
<input type="submit" value="$rss->{'textinput'}->{'title'}">
</form>
HTML
    }

    # if there's a copyright element
    if ($rss->{'channel'}->{'copyright'}) {
	print <<HTML;
<p><sub>$rss->{'channel'}->{'copyright'}</sub></p>
HTML
    }

    print <<HTML;
</td>
</TR>
</TABLE>
</td></tr></table>
HTML
}






