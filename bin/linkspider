#!/usr/bin/perl
#
# Bug: Doesn't ignore links in <!-- -->
#
#
# Copyright (C) 1996 by Joey Hess <joey@kitenet.net>
# Distribute under the terms of the GPL.

#############################################################################
##################### Begin configuration section ###########################
#############################################################################

# Subject of a message mailed to a user who has bad links on their pages:
$mail_subject="LinkSpider: Errors on your web pages";

# First part of message sent to user:
$mail_firstpart=<<eof;
LinkSpider, a web page validation robot, has detected the following 
bad links on your web pages:
eof
# It is followed by a list of the bad links, and then by this:
$mail_secondpart=<<eof;
If you don't want LinkSpider to visit a directory, just make a file named
.linkspider-ignore in the directory you want it to ignore. 

If you hate LinkSpider, and want it to keep off your web pages entirely,
send mail to Joey and ask for it to be stopped.
   
If you think you've found a bug in LinkSpider, email the author at
<joey\@kitenet.net> and describe it.
eof

# Possible names for an index file:
@index_extentions=('index.html','index.htm','default.htm','default.html');

# Possible extentions for html. These pages are checked for links, nothing 
# else is.
@html_extentions=('.html','.htm','.shtml');

# Directories to ignore (like -ignore flag)
@ignore=('^/cgi-bin/');

# Filename to store our datafile to. A good choice is something under /var
$datafile='/home/joey/prog/linkspider/linkspider.dat';

# How many times should we try an external url before notifying you of 
# a bad link?
$tries=5;

# How long should we try to connect to a host before giving up on it (seconds)
$timeout=120;

# If any of the following strings is returned when we try to load an url,
# we'll assume the url is bad. (Case insensitive)
# @url_not_found=();

# This text is displated if we detect that the user doesn't know what they're 
# doing.
$helptext=<<eof;
Linkspider is a html link validation program. It will scan an entire
web site on the computer it is run on, and notify you of missing links.
Optionally, it will check links that are not local to your server.

If a directory has a .linkspider-ignore file in it, then no files in
it will be checked.

Syntax:

linkspider.pl httpdroot [-external] [-users] [-verbose] [-help] [-ignore=dir ..]

  httpdroot The root directroy of your html tree.
  -external Check links to external web pages as well.
  -users    Follow links to user's homepages (/~user/)
  -mail   Mail the user who owns the page if it has bad links.
  -verbose  Produce lots of output (off by default)
  -help, -h Display this help message.
  -no.ignore  .linkspider-ignore file does not have any effect.
  -ignore=dir Specify a directory (in webspace) to ignore:
      no files under it will be checked
      Or just specify a single file to ignore.

eof

#############################################################################
###################### End configuration section ############################
#############################################################################

# Parse our command-line arguments.
sub ArgProc {
	foreach $flag (@ARGV) {
		$_=lc $flag;

		if ($_ eq '-help' or $_ eq '-h') { exit print $helptext }
		elsif ($_ eq '-external') { $external_flag=1 }
		elsif ($_ eq '-users') { $users_flag=1 }
		elsif ($_ eq '-verbose') { $verbose_flag=1 }
		elsif ($_ eq '-mail') { $mail_flag=1 }
		elsif ($_ eq '-no.ignore') { $no_ignore_flag=1 }
		elsif ($flag=~m/^-ignore=(.*)$/i ne '') { $ignore[$#ignore+1]=$1 }
		elsif (-e $flag ) { $startfile=$flag }
		else {
			print "Error: \"$flag\" is an unknown flag, or if you meant it to be a httpdroot, it doesn't exist. Aborting.\n\n";
			print $helptext;
			exit;
		}
	}

	if (!$startfile) { 
		exit print "Error: No httpdroot was specified\n\n$helptext";
	}

	if ($mail_flag && !$users_flag) {
		print "You specified -mail without -users, which makes no sense. Carrying on anyway.\n";
	}
}

# Remove any links to anchor urls in the file
# **These should be checked to see if the anchor does exist**
# Also remove the ?query_string after a cgi script.
sub TrimJunk { $_=shift;
	s/[\#|\?].*?$//;
	tr:/:/:s; # remove duplicate //'s.
	return $_;
}

# Check a local html file and follow all its links.
sub CheckFile_local { my ($fn,$parent_page)=@_;

	$fn=TrimJunk($fn);

	if (-d $fn) { #Try to find an index file.
		$fn=~s:/$::;
		$fn.='/';
		for (@index_extentions) {
			if (-e $fn.$_) {
				$fn.=$_;
				last;
			}
		}
		if ((-d $fn) && ($no_ignore_flag || !-e "$fn/.linkspider-ignore")) {
			&Log("Unable to find an index file for directory \"$fn\".\n");
		}
	}

	my ($dir)=$fn=~m/^(.*)\/.*?$/;

	# So, is this a file to be ignored?
	if (!$no_ignore_flag && -e "$dir/.linkspider-ignore") { return }

	foreach (@ignore) {
		if ($fn=~m/^$_/ ne '') { 
			&Log("Ignored: $fn\n");
			return;
		}
	}

	if (!-e $fn) { #Aha! bad link!
		if (int($data{"$fn\@$parent_page"}++) eq 0) {
			&Error("Bad link: `$parent_page' -> `$fn'\n",$parent_page);
		}
		return;
	}

	# See if this is a html file whose links we should follow.
	my $ok='';
	foreach (@html_extentions) {
		if ($fn=~/$_$/ ne '') {
			$ok=1;
			last;
		}
	}
	if (!$ok) { return }

	# Make sure we don't check any file twice.
	if ($checked{$fn}) {
		return;
	}
	else {
		$checked{$fn}=1;
	}

	&Log("Testing: $fn\n");

	open (IN,"<$fn") || exit print "<$fn: $!\n";
	# It's regrettable, but we have to store the whole page in memory.
	my @page=<IN>;
	close IN;
	my $page="@page";
	undef %page;

	$page=~tr/\n\t\r / /s;	
  $page=~s/ =/=/g;
	$page=~s/= /=/g;

	while ($page=~m/<IMG .*?SRC="(.*?)".*?>/gi) { #find <IMG SRC= links..
		&FollowLink($1,$dir,$fn);
	}
	while ($page=~m/<A .*?HREF="(.*?)".*?>/gi) { #find <A HREF= links..
		&FollowLink($1,$dir,$fn);
	}
}

# Check an external file, to see if it exists. Update our database of external 
# files appropriatly.
sub CheckFile_external { my ($fn,$parent)=@_;
	if (!$external_flag) { return }

	$fn=TrimJunk($fn);	
	
	# Parse the url, get hostname, port, and file.
	($host,$file)=split(/\//,$fn,2);
	$file="/$file";
	($host,$port)=split(/:/,$host,2);
	if (!$port) { $port=80 }

	# Make a note of what pages link to this external url.
	$parent_external{"$host:$port$file"}.="$parent|";  

	# Have we visited this one before?
	if ($checked_external{"$host:$port$file"}) {
		return;
	}
	else {
		$checked_external{"$host:$port$file"}=1;
	}	

	&Log("Testing: http://$host:$port$file\n");

	# Let's try to load up the url.
	# If the file is actually a directory, and doesn't have a / tacked on the
	# end, some webservers will say the file has moved. That's ok. Anything
	# except file not found or a timeout is ok.
	if (HttpGet($host,$port,$file) eq '') { # looks like a bad link
		$data{"$host:$port$file"}++;
	}
	else { # looks like a good link.
		$data{"$host:$port$file"}=0;
	}
}

# Warn people if too many days have gone by without being able to contact
# external urls.
sub Warn_external {
	foreach $key (keys(%checked_external)) {
		if ($data{$key} eq $tries) { #time to let someone know.
			for $parent (split(/\|/,$parent_external{$key})) {
				if ($parent) {
					&Error("Bad link: `$parent' -> `http://$key'\n",$parent);
				}
			}
		}
	}
}

# Given a hostname, a port, and a file, go get it via http, and
# return 1 if it seems to be a valid page, '' otherwise.
# This currently uses netcat (nc) to do the dirty work, and speaks the
# http/1.0 protocol.
#
sub HttpGet { my ($host,$port,$file)=@_;
	# Get the page
	my @ret=`(echo \"GET $file HTTP/1.0\"; echo \"\") | nc $host $port -w $timeout`;
	my $top=shift @ret; #topmost header. 
	while (shift @ret ne "\n") { last if $#ret eq -1 } # Work through header.
	$r=join('',@ret);
	# Check to see if it looks valid.

	# Check the status line.
	my ($status)=$top=~m/^HTTP\/1.0 (\d+) .*/i;
	if (int($status) >= 400) { &Log("$host:$port$file bad status\n") ; return '' }

	# Check the length of the page.
	if (!$r and !$top) { &Log("$host:$port$file timed out\n") ; return '' }

	# Check for keywords that tell us something is wrong.
	foreach(@url_not_found) {
		if ($r=~m/$_/i ne '') { &Log("$host:$port$file has bad keyword\n") ; return '' }
	}
	
	# Looks good, then..
	return 1;
}

# Given a link, a current directory, and a parent filename,
# figure out what we must do to follow on the the file on the
# other side of the link
#
# This handles ./, ../, differentiating urls and local filenames, 
# and all that nasty stuff.
#
sub FollowLink { my ($link,$dir,$fn)=@_;
	$_=$link;
	if ($_ eq '.') {
		# Check index file for this directory.
		&CheckFile_local($dir,$fn);
	}
	elsif (/^\.\/(.*)$/ ne '') {
		# Stay in present directory. 
		# (Only 1 ./ allowed in a filename. Pah.)
		&CheckFile_local("$dir/$1",$fn);
	}
	elsif (/^\.\.\// ne '') { #../ to a different directory.
		# "../dir/../" is NOT handled. 
		# "../../" is handled, to any depth.
		my (@dirs)=split(/\//,$_);
		my (@dir2s)=split(/\//,$dir);
		my $fn2='';
		foreach (@dirs) {
			if ($_ ne '..') { $fn2.="/$_" } else { pop @dir2s }
		}
		&CheckFile_local(join('/',@dir2s).$fn2,$fn);
	}
	elsif (/^\/(.*)$/ ne '') {
		# Absolute filename or user directory.
		
		$_=$1;
		if (/^~(.*?)\/(.*?)$/ ne '') { # match home directories.
			if ($users_flag) { 
				&CheckFile_local("/home/$1/html/$2",$fn); # **unfortunate hardwiring here.**
			}
		}				
		else {
			&CheckFile_local("$startfile/$1",$fn);
		}
	}
	elsif (/^.*?:\/\// eq '' and /^mailto:/i eq '' and /^news:/i eq '' 
	       and /^gopher:/i eq '' and /^telnet:/i eq '') {
		# File in same directory.
		&CheckFile_local("$dir/$_",$fn);
	}
	elsif (/^http:\/\/(.*)/ ne '') {
		# External link.
		CheckFile_external($1,$fn);
	}
}

# Output this info if we are being verbose
sub Log { my $text=shift;
	print $text if $verbose_flag;
}

# Inform a user of an error.
#
# If you specified the -mail flag, we mail the user in question a 
# helpful message.
#
# Generally, we just print the error to stdout, and let cron do the work.
#
sub Error { my ($text,$fn)=@_;
	if (($mail_flag) && ($fn=~m:^/home/(.*?)/html/: ne '')) { #mail to user. (**More unfortunate hardwiring)
		$user_mail{$1}.=$text;
	}
	else {
		print $text;
	}
}

# This sends mail to any users who have errors in their html.
sub MailUsers {
	foreach $user (keys(%user_mail)) {
		open (MAIL,"|mail $user -s \"$mail_subject\"");
		print MAIL "$mail_firstpart\n$user_mail{$user}\n$mail_secondpart";
		close MAIL;
	}
}

#Load up our datafile, if any.
#
#The datafile has 2 formats. The one for external links is:
#
# Number:Url
#
# Number is the number of times LinkSpider has tried, and failed, 
# to connect to Url
#
# For internal links, it uses this format:
#
# Number:Bad link@Parent Page
#
sub LoadDatafile {
	open (IN,"<$datafile") || print "Unable to read $datafile.
	If this is the 1st time you've run LinkSpider, this is 
	normal. Otherwise, we've lost some data. Carrying on..\n";
	while (<IN>) {
		chomp;
		($count,$url)=split(/:/,$_,2);
		$data{$url}=$count;
	}
	close IN;
}

#Save our datafile.
sub SaveDatafile {
	open (OUT,">$datafile") || print "Unable to write to $datafile! Lost some data!\n";
	foreach $key (keys(%data)) {
		if (($checked_external{$key}) || ($key=~/\@/ ne '')) {
			print OUT "$data{$key}:$key\n";
		}
	}
	close OUT;
}

&ArgProc;
&LoadDatafile;
&CheckFile_local($startfile,'[httpdroot]');
&Warn_external;
if ($mail_flag) { &MailUsers }
&SaveDatafile;
