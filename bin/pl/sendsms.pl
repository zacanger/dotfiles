#!/usr/bin/env perl
##############################################################################
# SMS sending script for Israeli cellular phones: Cellcom, Orange (Partner),
# Pelephone, and Amigo (Mirs).
#
# English, and Hebrew (ISO-8859-8 Logical encoding) messages supported for
# all providers (but not all phones in all providers support Hebrew SMSs).
##############################################################################
#
#Copyright (C) 1999-2005 Nadav Har'El (http://harel.org.il/nadav)
#Portions by Dan Kenigsberg, Alon Altman, and others
#License: GNU GPL *with the following exception*
#  GPL Exception: This script may not be used for the purpose of mass
#  unsolicited message distribution (spam).
#
# Version 3.11, [April 12, 2005]
# For version history, see below.
# The latest version of this script can be found in
#    http://harel.org.il/nadav/software/sendsms
#
##############################################################################
#
#Installation instructions: (don't forget to read this part!)
#
#1. You'll have to install the following perl libraries first
#    Digest-MD5   MIME-Base64  libnet
#    HTML-Parser  URI          libwww-perl
#    Crypt-SSLeay
#
#   Some Linux distributions (such as Redhat) already include all these
#   useful libraries by default so you don't need to do anything.
#
#   If you haven't installed these libraries in your system's official Perl
#   module directory, you'll need to tell sendsms where to find the libraries.
#   Either change the "BEGIN" line below to list the directory where you
#   installed these libraries. Or, if you don't want to modify the sendsms
#   script, you can set the PERLLIB environment variable to point to the
#   directory where you installed the libraries. For example, to run sendsms
#   without any modifications even if your Perl and Perl libraries are
#   installed in non-standard locations, you can run something like this:
#	PERLLIB=/directory/of/perl/libraries perl -w /where/you/put/sendsms
#
#2. To send SMSs to phones of each of the supported providers, you will need
#   to register online and get free SMS-sending acounts:
#   Amigo:
#           http://www.amigo.co.il/html/login/new_user.asp
#            - Hebrew site only
#   Cellcom, Pelephone or Orange:
#           http://web.icq.com/sms/login (or any ICQ client)
#            - Does not require a Cellcom or Pelephone phone; English site.
#            - If you already have an ICQ account, you can use it.
#   Orange:
#           http://www.orange.co.il/default.asp?page=/registration/main.asp
#            - Completing registration requires owning an Orange phone!
#            - Hebrew site only
#            - Might not work on any browser except Microsoft Internet Explorer 
#
#3. Create a file ".sendsmsrc" in your home directory, to include at least
#   information about these provider accounts. Use the commands
#	account amigo USER PASSWORD
#       account icq NUMBER PASSWORD        (or email instead of number)
#	account orange USER PASSWORD
#   using the accounts you acquired above. If you do not do that for a
#   particular company, you won't be able to send SMSs to numbers in that
#   company. You may have more than one account for each provider - in that
#   case one of the accounts is chosen at random on every invocation of
#   sendsms (the reason you might want to have more than one account is that
#   most providers limit each account to 20 messages per day).
#   The ~/.sendsmsrc file can also contain a proxy definition, aliases, and
#   including of other files. See the sendsms(1) manual for more information.
#
##############################################################################
# SendSMS Version History:
#
# 3.11: April 12, 2005
#       * Support ICQ's changed site (for Orange, Cellcom and Pelephone).
#         This support now requires the Crypt-SSLeay Perl module (for SSL).
# 3.10: March 31, 2005
#	* An ICQ account, which previously enabled sending SMSs to Pelephone
#	  and Cellcom phones, now also allows sending messages to Orange
#	  phones. This method is used if an "orange" account is not set in
#	  the .sendsmsrc. (thanks to Dan Kenigsberg)
#	* Sendsms should now work on Windows (ActiveState Perl). The sendsmsrc
#	  file in Windows resides in $HOMEDRIVE$HOMEPATH\sendsmsrc (no initial
#	  dot in the file name). (thanks to Nimrod Zimerman)
#	* Fixed 7-digit number support for Amigo (thanks to Amir Friedman)
#	* New -f option for choosing a different config file (thanks to Dan
#	  Kenigsberg).
# 3.9: October 11, 2004 (Nadav Har'El, Dan Kenigsberg)
#       * Accept new 7-digit phone numbers, as well as old 6-digits numbers.
#         (thanks to Dan Kenigsberg)
# 3.8: December 24, 2003 (Netta Gavrieli, Elad Barkan, Dan Kenigsberg,
#                         Gil Ratsabi)
#       * Fixed Hebrew support for Cellcom phones (thanks to Netta Gavrieli)
#         Note that arguments must be in iso8859-8, regardless of the locale.
#	* Fixed treatment of long ICQ passwords (thanks to Gil Ratsabi)
#       * Fixed Orange support after two site changes (Elad Barkan and
#         Dan Kenigsberg)
# 3.7: September 7, 2003 (Nadav Har'El)
#       * Pelephone's old site no longer works (the new one requires owning
#         a pelephone phone, and apparently costs money). Instead, we started
#         using ICQ's site (previously used for Cellcom, needs a free account).
#       * Fixed 065 support.
#       * Sending Hebrew to Cellcom and Pelephone phones now works (only
#         tested from a shell running with a ISO-8859-8 locale).
# 3.6: July 27, 2003 (Dan Kenigsberg)
#       * Fixed recognition of successful sending of an Orange message.
# 3.5: June 20, 2003 (Nadav Har'El)
#       * Support for ICQ's modified site (for sending Cellcom messages).
#         No longer requires SSL or installing the SSLeay package.
#       * Added 066 area code for Orange and 065 for Cellcom.
# 3.4: June 6, 2003 (Nadav Har'El and Eran Tromer)
#       * Support for Orange's modified site.
#       * Support for Cellcom's own interface (which now costs money) is
#         withdrawn; Sendsms can still send SMSs to Cellcom phones using
#         the ICQ interface.
# 3.3: October 27, 2002 (Nadav Har'El, Dan Kenigsberg and Elad Barkan)
#       * Newlines in messages now work in Orange.co.il
#       * Can now send messages to Cellcom phones using ICQ's free web
#         interface (requires either an ICQ number or free registration, but
#         not a cellcom phone). Requires Crypt-SSLeay library for SSL.
#       * sms.gt.com.ua no longer works, so support for it has been withdrawn.
# 3.2: September 17, 2002 (Nadav Har'El, Dan Kenigsberg, Alon Altman)
#	* Orangewalla service no longer works. Instead support the
#         http://sms.gt.com.ua/ and orange.co.il interfaces.
#       * Added 068 area code for Pelephone.
#       * Cellcom support trys to warn if Cellcom's service stops being free.
# 3.1: July 6, 2002 (Nadav Har'El)
#       * Support for Cellcom's new site (old site taken down in June 26 2002).
#         Note that users must get a new iCellcom account.
# 3.0: May 1, 2002 (Nadav Har'El)
#	* Read ~/.sendsmsrc file for accounts, proxy settings and aliases.
#       * Support for Amigo's new site (amigo.co.il)
#       * New manual page (sendsms.1)
# 2.7: April 21, 2002 (Nadav Har'El)
#       * Fixed for changes in Cellcom's site done in April 21, 2002.
# 2.6: December 11, 2001 (Nadav Har'El)
#       * Fixed for changes in Orange-Walla's site done Dec 11, 2001, 14:00 IST
#       * Truncate too-long messages that Orange-Walla's site will drop.
# 2.5: December 10, 2001 (Nadav Har'El)
#       * Improve error reporting for Cellcom.
#	* Allow sending empty message to Cellcom (converted to a single space).
#       * Fixed for changes in Cellcom's site done around Dec 10, 2001.
# 2.4: November 11, 2001 (Nadav Har'El and Dan Kenigsberg)
#       * Added 067 area code for Orange.
#	* Orange's SMS sending web interface stopped working. Use Orange-Walla
#	  instead.
# 2.3: May 22, 2001 (Nadav Har'El).
#       * Fixed for changes in Orange's site done in May 20-21, 2001.
# 2.2: May 9, 2001 (Nadav Har'El)
#       * Added logical-Hebrew support for Pelephone (the previous version did
#         visual Hebrew. The "-l" option reverts back to visual Hebrew when
#         this is a Hebrew-supporting phone (latin1 is not supported).
#       * Added Mirs (Amigo) support.
# 2.1: May 5, 2001 (Nadav Har'El)
#       * Added command line uptions: u (urgency, for cellcom), l, h (encoding)
#       * Added support for Hebrew SMS in Orange and Cellcom (the -l option is
#         used to specify Latin1, NOT Hebrew). Note that Hebrew SMS only works
#         on certain provider/phone combinations, and sendsms cannot always
#	  know if the Hebrew send succeeded (in Cellcom, it can).
#       * As of April 2001, Cellcom has a fourth area code: 064.
# 2.0: May 1, 2001 (Nadav Har'El)
#       Added Pelephone support, finally. It uses Pelephone's own web
#       form for sending SMSs (no "account" is necessary). An alternative,
#       email-gateway-based, approach appears commented out in the code.
#       A stub was added for the new Mirs Amigo, but no actual support for
#       it yet.
# <2.0: (Nadav Har'El)
#       Versions released between 1999 and April 2001 were written in Perl
#       and supported Orange and Cellcom phones. Several times during this
#       period one of these companies' site has changed (sometimes a bit,
#       and sometimes a complete overhaul) and the interaction with it had
#       to be rewritten. A history of these versions was not kept (except
#       in this file's RCS history which is not public).
# <1.0: (Nadav Har'El)
#       Versions released between June and August of 1999 supported only
#	Orange phones, using the now-defunct GoSMS web interface. They were
#	shell scripts, using wget for the actual HTTP interaction.
##############################################################################

#TODO: convert this to object oriented, with different classes for different
# companies with the same interface (use interitance).

require 5.004;
BEGIN {push @INC, ("/home/nyh/sendsms/newlib/lib/perl5/site_perl/5.8.0","/home/nyh/sendsms/newlib/lib/perl5/site_perl/5.8.0/sun4-solaris/")}

# The following should be available on any modern Perl installation
use strict;
use Carp;
use Getopt::Std;
use IO::File; # for recursive configuration-file reading
use Encode; # ICQ wants utf-8 encoding.

# The following usually requires installation (see comment above about that)
use LWP::UserAgent;
use URI::Escape;
use HTTP::Cookies;

#############################################################################

# process command line options:

my %opts;
getopts('lhu:f:', \%opts);

# Read the user's configuration file (if any)

# note: if for some reason you want to make this script self-contained (without
# requiring an external ~/.sendsmsrc file), set the following variables here
# and remove the readrc call below...
my ($n_account_orange,$ORANGE_USER,$ORANGE_PASSWORD)=0;
my ($n_account_amigo,$AMIGO_USER,$AMIGO_PASSWORD)=0;
my ($n_account_icq,$ICQ_USER,$ICQ_PASSWORD)=0;
my ($http_proxy,%aliases);
my ($pay_orange)=0;

sub readrc {
	my $filename = shift;
	my $RC = new IO::File;
	$RC->open($filename) or return 0;
	while(<$RC>){
		chomp;
		if(/^\s*#|^\s*$/o){
			# ignore comments and whitespace
		} elsif(/^\s*account\s+orange\s+(\S*)\s+(\S*)\s*$/o){
			# a nice trick for picking a random account without
			# needing to remember the whole array!
	        	if(rand(1)*($n_account_orange++) < 1){
		          ($ORANGE_USER,$ORANGE_PASSWORD)=($1,$2);
			}
		} elsif(/^\s*account\s+amigo\s+(\S*)\s+(\S*)\s*$/o){
	        	if(rand(1)*($n_account_amigo++) < 1){
		          ($AMIGO_USER,$AMIGO_PASSWORD)=($1,$2);
			}
		} elsif(/^\s*account\s+icq\s+(\S*)\s+(\S*)\s*$/o){
	        	if(rand(1)*($n_account_icq++) < 1){
		          ($ICQ_USER,$ICQ_PASSWORD)=($1,$2);
			  $ICQ_PASSWORD =~ s/^(........).*/$1/;
			}
		} elsif(/^\s*(http_)?proxy\s+(\S+)\s*$/o){
			$http_proxy=$2;
		} elsif(/^\s*alias\s+(\S+)\s+(\S+)\s*$/o){
			$aliases{$1}=$2;
		} elsif(/^\s*pay_orange\s+(true|false)\s*$/o){
			$pay_orange = ($1 eq 'true');
		} elsif(/^\s*include\s+(.*)\s*$/o){
			readrc($1) or warn "Could not include file '$1'\n";
		} else {
			warn "Syntax error in ~/.sendsmsrc: '".$_."'\n";
		}
	}
	# note that close($RC) is automatic when the function ends.
	return 1;
}

# Config file to read: ~/.sendsmsrc on Unix-like systems,
# $HOMEDRIVE$HOMEPATH\sendsmsrc on Windows, or user specified file if the
# "-f" option was given:
my $winhome = $ENV{"HOMEDRIVE"}.$ENV{"HOMEPATH"};
my $rcfile = ($winhome eq "") ? glob("~/.sendsmsrc") : $winhome."\\sendsmsrc";
$rcfile = $opts{f} if exists ($opts{f});

readrc($rcfile);

#############################################################################

# some more checks on these command line options:

#TODO: this piece of code is Cellcom-specific - move it to the cellcom section
# after I decide what to do about addding an urgency option to Orange and
# Pelephone. THIS CODE DOESN'T HAVE ANY EFFECT IN THIS VERSION!
if(exists($opts{u})){
	# Cellcom allows 1 ("Normal"), 2 ("Urgent") or 3 ("Emergency")
	# messages. Emergency messages, for example get listed on the phone
	# as "new emergency message", and so on.
	# TODO: Pelephone also allows urgency parameter - test it and use it.
	# check if orange also has one. Make the urgency parameter the same
	# for all providers.
	if($opts{u}!="1" && $opts{u}!="2" && $opts{u}!="3"){
		print STDERR "Error: Urgency (-u) can be '1', '2' or '3'.\n";
		exit 8;
		$opts{u}="1";
	}
} else {
	$opts{u}="1";
}

# When we have non-ascii characters in the message, we need to know if they
# are supposed to be Hebrew, or Latin1 characters. Not all provider/phone
# combinations support Hebrew at all (and some support Hebrew do not support
# Latin1), but some do support both - e.g., Nokia 5120 on Orange (it's non-
# Hebrew encoding isn't exactly Latin1, but many important accented latin
# characters are the same).
# Note that the default "h" (Hebrew, ISO-8859-8) encoding, does not mean that
# the message has to be Hebrew - it can be a completely ASCII message too.
# Also, when the message does contain Hebrew, it should be "logical" hebrew/
# latin mix (e.g., the word "kelev" is written kaf, lamed, bet, in that order).
# This version does not support other encodings. I don't think that Israeli
# cellphone companies support SMSs in character-sets besides Hebrew and Latin1.
# Using UTF8 encoding MAY work (I didn't check!), but only if the appropriate
# "-l" or "-h" options is used (the choice isn't automatic).
if(exists($opts{h}) && exists($opts{l})){
	print STDERR "Error: Conflicting options -h (ISO-8859-8) and -l (ISO-8859-1) given.\n";
	exit 8;
}
if(!exists($opts{h}) && !exists($opts{l})){
	$opts{h}=1;
}


if($#ARGV+1 != 3){
	print STDERR "Usage: $0 [-lh] [-u 1/2/3] phonenum sender message\n";
	exit 1;
}

my $phonenum=$ARGV[0];
# check if it's an alias
$phonenum = $aliases{$phonenum} if(exists($aliases{$phonenum}));
# remove optional spaces, parantheses, or hyphens from phone number
$phonenum =~ s/[ ()-]//go;
my $sender=$ARGV[1];
my $message=$ARGV[2];

$phonenum = &sixtoseven($phonenum) if $phonenum =~ m/^05[0-9][0-9]{6}$/;

my ($t_sec,$t_min,$t_hour,$t_mday,$t_mon,$t_year,$t_wday,$t_yday,$t_isdst) =
	localtime(time);
print STDERR sprintf("[%02d/%02d/%02d %02d:%02d] ",$t_year%100,$t_mon+1,$t_mday,
	$t_hour,$t_min).  "Sending to $phonenum: $message ($sender)\n";

##################################
my ($ua,$req);

#$ua = new LWP::UserAgent(keep_alive => 1);
$ua = new LWP::UserAgent;

# Just some arbitrary (but real-looking, in case some site checks) user agent
$ua->agent("Mozilla/4.73 [en] (Win95; I)");

# if no "proxy" (or "http_proxy") command is given in ~/.sendsmsrc, the
# environment variables http_proxy and no_proxy are used to choose a proxy (if
# any) - see env_proxy in LWP's UserAgent.pm. If a "proxy none" command is
# given, a proxy is not used (regardless of the environment variables set).
# Otherwise, a command like "proxy http://proxy.com:8080/" sets an http proxy.
if(defined $http_proxy){
	if($http_proxy ne "none"){
		$ua->proxy('http', $http_proxy);
	} 
} else {
	$ua->env_proxy();
}

############################ ORANGE ########################################
# Written by Dan Kenigsberg and Nadav Har'El, with assistance of Elad Barkan
sub sendsms_orange {
	my %args = @_;

	if($args{phonenum} !~ m/^0((5[45]|6[67])[0-9]{6}|54[0-9]{7})$/){
		return 0;
	}

	# Orange.co.il does not support "sender". Let's just append it to
	# the message, in parantheses:
	if($args{sender} ne ""){
		$args{message} = $args{message} . " (" . $args{sender} . ")"
	}

        # orange.co.il's form allows a maximum of 142 characters in an English
	# message, 49 in an Hebrew one. But this is just to make sure they can
	# stick their site name at the end. We can actually use more: 160 and
	# 70 respectively.
	# In the future, we might even want to put spaces at the end of the
	# message to make sure the "orange.co.il" advertisement doesn't fit :)
	my $ishebrew=0;
	if($opts{h} && ($args{message}=~ /[\200-\377]/)){
		$ishebrew=1;
		if(length($args{message}) > 70){
			print STDERR "Warning: truncating Hebrew sender+".
				"message at 70 characters...\n";
			$args{message}=substr($args{message},0,70);
		}
	} else {
		if(length($args{message}) > 160){
			print STDERR "Warning: truncating sender+message at ".
				"160 characters...\n";
			$args{message}=substr($args{message},0,160);
		}
	}

	# Newlines in the message used to get ignored, and we needed to
	# change them into carriage-return-line-feed. This is no longer true.
	#$args{message} =~ s/\n/\r\n/g;

	my $res;
	my $base = "http://orange.co.il";

	# check that we still have messages in our free quota. messages
	# beyond the first 20 per day cost money, and we wouldn't want that
	# to happen by accident!
	if(!$pay_orange){
	# The three GETs we will do now have no function other than to check the
	# free message quota, and can be safely not done if such check is not
	# required.
	# Important note: The fact that the free-message quota check is done
        # in out-of-band means (not on the sms sending page) and that we are
	# checking Javascript, not user-visible messages like before, is
	# problematic, because it lowers the user's stand if and when a user
	# is falsely billed for what should have been free messages (he can't
	# claim "but I saw a message telling me the message is free!").
	# In particular: we know that $base/phone_book/scripts/send.js
	# prints out 'maxperday' as the number of free messages left and this
	# is why we check this variable (found in scripts/send.aspx? - all of
	# these javascripts are used from sendsms.aspx). But we do not
	# actually verify that send.js continues to use this variable for
	# this purpose.
	# TODO:  Maybe we should get send.js and look for the string:
	#    maxperday + txtMid.replace("ססס","בחינם")
	#
	# THE FOLLOWING COMMENT IS OLD AND WAS NOT VERIFIED TO BE CURRENT:
	# Important note: this test is not foolproof when many messages are
	# sent very quickly, and another message is sent between our check
	# of the quota and the actual sending. In this case you might get
	# charged for one message :( But in practice, to get charged you
	# need to get another password to your phone (every day), so this
	# cannot happen accidentally.
	# The second GET is just for the ASP.NET_SessionId, needed in the
	# third GET. The second GET needs some cookie from the first GET.
        # Eeek...

        $req = new HTTP::Request POST => "$base/content_site/login_check.aspx";
        $req->header('Accept' => 'text/html');
        $req->content("func=&mode=&page=http%3A%2F%2Forange.co.il%2Fcontent_site%2Fmain.aspx%3FsiteId%3D1&mfn=".$args{user}."&iccid=".$args{password});
        my $cookie_jar = HTTP::Cookies->new;
        $res = $ua->request($req);
        $cookie_jar->extract_cookies($res);

        $req = new HTTP::Request GET => "$base/content_site/sendsms.aspx";
	$req->header('Accept' => 'text/html');
	$req->header('Cookie' => "pass=".$args{password}.
				";name=".$args{user});
	$res = $ua->request($req);
	$cookie_jar->extract_cookies($res);
        $req = new HTTP::Request GET => "$base/content_site/scripts/send.aspx?";
	$req->header('Accept' => 'text/html');
	$req->header('Cookie' => "pass=".$args{password}.
				";name=".$args{user});
	$cookie_jar->add_cookie_header($req);
	$res = $ua->request($req);
	if(!$res->is_success ||
           $res->content !~ /function initCounters\(\)\{maxperday = ([0-9]+);maxperdaypay =/){
		print STDERR "Error: unexpected response from Orange's site when checking free SMS quota\n";
		#print STDERR "-------- THE ERROR: --------\n".
		#	$req->as_string. "\n". $res->as_string. "\n".
		#	"----------------------------\n";
		print STDERR "\nYou can put 'pay_orange true' in ~/.sendsmsrc to avoid this test.\nUse at your own risk!\n";
		exit 11;
	}
	#print "Info: $1 free messages were left\n";
	if($1<1){
		print STDERR "Warning: depleted daily quota of free SMS. Sending may not be free.\n";
		print STDERR "Not sending message, to avoid charge!\n";
		exit 7;
	}
	}
	# end of verification that we can send free messages.

	# Now, send the message. Note that no use is made of the sender
        # supplied by the user (we put it inside the message above).
        $req = new HTTP::Request POST => "$base/content_site/smsprocess.aspx";
	$req->content_type('application/x-www-form-urlencoded');
	$req->content("hebrew=".($ishebrew?"0":"1")."&".
		"message=".uri_escape($args{message}, "^A-Za-z0-9")."&".
		"msisdns=".$args{phonenum});
	$req->header('Accept' => 'text/html');

	# put the cookies in the header.
	# happily, orangecoil's are easy to create locally.
	$req->header('Cookie' => "pass=".$args{password}.
				";name=".$args{user});
	$res = $ua->request($req);

	## Check if the sending succeeded
	if ($res->is_success) {
		if($res->content =~ m!הודעתך נשלחה בהצלחה!){
			print STDERR "Sent successfully.\n";
		} elsif($res->content =~ /location.href='.phone_book.'/){
			print STDERR "Error: Could not send message, for ".
			 " an unknown reason. Perhaps your acount was\n  ".
	                 "not activated with an Orange phone number? Try ".
			 "sending a message yourself\n  using ".
			 "http://orange.co.il\n";
			exit 6;
		} else {
			# TODO: try to recover somehow maybe try to figure out
			# what went wrong by looking at $res->content.
			print STDERR "Error: unexpected response from Oranges's site\n";
			print STDERR "-------- THE ERROR: --------\n".
	                     $req->as_string. "\n".
	                     $res->as_string. "\n".
	                     "----------------------------\n";
			exit 6;
		}
	} else {
		# TODO: retry several times, sleeping between tries.
		print STDERR "Error sending message: " . $res->status_line . "\n";
		#print STDERR "-------- THE ERROR: --------\n".
	        #             $res->content. "\n".
	        #             "----------------------------\n";
		exit 5;
	}
	return 1;
}

# sendsms_icq recognizes the following arguments:
#  sender, phonenum, message, user, password
# Written by Nadav Har'El and Dan Kenigsberg
sub sendsms_icq {
	my %args = @_;

	# ICQ.com does not support "sender". Let's just append it to the
	# message, in parantheses:
	if($args{sender} ne ""){
		$args{message} = $args{message} . " (" . $args{sender} . ")"
	}

	# ICQ expects the message to be in UTF-8 encoding. If the user uses
	# some other encoding (according to their locale) we need to convert.
	# TODO: currently, we explicitly convert from iso-8859-8. But wouldn't
	# it be better if we knew which locale the user is using?
        $args{message} = decode("iso-8859-8", $args{message});
	$args{message} = encode("utf-8", $args{message});

	# We need to truncate too-long messages, because it appears that ICQ
	# silently drop them.
	if(length($args{message}) > 160){
		print STDERR "Warning: truncating sender+message at ".
			"160 characters...\n";
		$args{message}=substr($args{message},0,160);
	}
	# It appears that ICQ.com changes single-quotes into the string
	# \27 - eek! I couldn't find a way around this problem, so our
	# only resort for now is to change it into a reverse quote (`).
	$args{message} =~ tr/'/`/;
	
	my $res;
	my $cookie_jar = HTTP::Cookies->new;
	my $ntries=0;

	## log in:
	while(1){
	if($ntries>=4){
		print STDERR "Failed $ntries login attempts - giving up.\n";
		exit 3;
	};
	# sleep a little until the next try
	sleep(30*$ntries*$ntries) if ($ntries>0);
	$ntries++;

	# Login step 1: get sms/login.php page, which then redirects to
	# the real https login page, which LWP then continues to get.
	# All we really need this step for is to get the hidden icq_ln
	# field of the form, and of course, cookies.
	$req = new HTTP::Request GET => "http://www.icq.com/sms/login.php";
	$req->header('Accept' => 'text/html');
	$res = $ua->request($req);
	$cookie_jar->extract_cookies($res);
	my $icqln;
	if($res->as_string =~ /name="icq_ln" value="([^\"]*)"/){
		$icqln=$1;
	} else {
		print STDERR "ERROR: failed to find icq_ln in login form...\n";
		next;
	}

	# Login step 2: fill the login form.
	$req = new HTTP::Request POST => "https://www.icq.com/karma/login.php";
	$req->header('Accept' => 'text/html');
	$req->content_type('application/x-www-form-urlencoded');
	$req->content("uin_email=".uri_escape($args{user}, '^A-Za-z0-9')."&".
		"password=".uri_escape($args{password}, '^A-Za-z0-9')."&".
		"lang=eng&dest=http%3A%2F%2Fwww.icq.com%2Fsms%2Flogin.php&".
		"service=&css=sms&icq_ln=$icqln&rem=1");
	$cookie_jar->add_cookie_header($req);
	$res = $ua->request($req);
	$cookie_jar->extract_cookies($res);
	if($res->code==200 && $res->content =~ m@www.icq.com/sms/login.php@){
		if($ntries>1){
			print STDERR "Success on attempt #$ntries\n";
		}
		last; # stop retrying
	} elsif($res->code==200 && $res->content =~ m@login_page.php\?error_msg=([^&]*)&@){
		print STDERR "Failed login to ICQ. Error message:\n";
		my $icqmsg = uri_unescape($1);
		$icqmsg =~ tr/+/ /;
		print STDERR "\"".$icqmsg."\"\n";
		exit 6;
	} else {
		print STDERR "Error: " . $res->status_line . "\n";
		print STDERR "-------- THE ERROR: --------\n".
		     $req->as_string. "\n".
		     $res->as_string. "\n".
		     "----------------------------\n";
		# go on to try again
	}
	}

	## Send message
	$ntries=0;
	while(1){
	if($ntries>=4){
		print STDERR "Failed $ntries send attempts - giving up.\n";
		exit 3;
	};
	# sleep a little until the next try
	sleep(30*$ntries*$ntries) if ($ntries>0);
	$ntries++;
	$req = new HTTP::Request POST => "http://www.icq.com/sms/send_msg_tx.php";
	$req->header('Accept' => 'text/html');
	$req->content_type('application/x-www-form-urlencoded');
	$req->content("country=972&prefix=%2B972&uSend=1&charcount=".(160-length($args{message}))."&".
		"carrier=".substr($args{phonenum},1,2)."&".
		"tophone=".substr($args{phonenum},3)."&".
		"msg=".uri_escape($args{message}, '^A-Za-z0-9'));
	$cookie_jar->add_cookie_header($req);
	$res = $ua->request($req);
	$cookie_jar->extract_cookies($res);
	if($res->code==302 && $res->header('location') =~ m@^/sms/thanks@){
		if($ntries>1){
			print STDERR "Success on attempt #$ntries\n";
		}
		print STDERR "Sent successfully.\n";
		last; # stop retrying
	# Errors cause redirection to http://www.icq.com/sms/error.php?id=N
	# for various N. Browsing these pages, I decided which are permanent
	# errors and which should cause a retry. These are the errors:
	# 1,2: Callback number invalid. 3: Message too long.
	# 11, 12: invalid cellular network.
	# 20: The user can't get SMS Messages from ICQ.
	# 4,5,6,7,8,9,10,16,17,18,19,21...: Error occured, please try again.
	# 14, 15: try again later. 13: Daily SMS message-sending limit.
	# TODO: 13 is only worth retrying if there are other user/password
	#
	} elsif($res->code==302 && $res->header('location') =~ m@^/sms/error.php\?id=\(1|2|3|11|12|20|13\)@){
		print STDERR "ICQ refused to send the message: see http://www.icq.com".$res->header('location').".\n";
		last; # stop retrying
	} elsif($res->code==302 && $res->header('location') =~ m@^/sms/error.php@){
		print STDERR "ICQ temporary failure: see http://www.icq.com".$res->header('location').".\n";
	} else {
		print STDERR "Error: " . $res->status_line . "\n";
		print STDERR "-------- THE ERROR: --------\n".
		     $req->as_string. "\n".
		     $res->as_string. "\n".
		     "----------------------------\n";
		# go on to try again
	}
	}
}


############################################################################
if($phonenum =~ m/^0((5[238]|6[45])[0-9]{6}|52[0-9]{7})$/){
############################ CELLCOM #######################################
	if($n_account_icq>0){
	        sendsms_icq(sender => $sender, phonenum => $phonenum,
			message => $message,
			user => $ICQ_USER, password => $ICQ_PASSWORD);
		exit 0;
	}
	print STDERR "\nERROR: No ICQ SMS account defined in ".
		 "your ~/.sendsmsrc!\nPlease see 'man sendsms' for ".
		 "instructions.\n";
		exit 1;
############################################################################
} elsif(defined $ORANGE_USER && defined $ORANGE_PASSWORD &&
        sendsms_orange(sender => $sender, phonenum => $phonenum,
		message => $message,
		user => $ORANGE_USER, password => $ORANGE_PASSWORD)){
	# ok
############################################################################
} elsif($phonenum =~ m/^0((5[45])[0-9]{6}|54[0-9]{7})$/){
############################ ORANGE, Through ICQ ###########################
	if($n_account_icq>0){
	        sendsms_icq(sender => $sender, phonenum => $phonenum,
			message => $message,
			user => $ICQ_USER, password => $ICQ_PASSWORD);
		exit 0;
	}
	print STDERR "\nERROR: Can't send SMS to Orange because no Orange or ICQ account defined in ".
		 "your ~/.sendsmsrc!\nPlease see 'man sendsms' for ".
		 "instructions.\n";
		exit 1;
############################################################################
} elsif($phonenum =~ m/^0((5[016]|68)[0-9]{6}|50[0-9]{7})$/){
############################ PELEPHONE #####################################
	if($n_account_icq>0){
	        sendsms_icq(sender => $sender, phonenum => $phonenum,
			message => $message,
			user => $ICQ_USER, password => $ICQ_PASSWORD);
		exit 0;
	}
	print STDERR "\nERROR: No ICQ SMS account defined in ".
		 "your ~/.sendsmsrc!\nPlease see 'man sendsms' for ".
		 "instructions.\n";
		exit 1;
############################################################################
} elsif($phonenum =~ m/^057[0-9]{7}$/){
############################## AMIGO #######################################
	if($n_account_amigo==0){
		print STDERR "\nERROR: No Amigo SMS account defined in ".
		 "your ~/.sendsmsrc!\n\nPlease get a free account from:\n  ".
		 "http://www.amigo.co.il/html/login/new_user.asp\n".
		 "and put in your ~/.sendsmsrc at least one line like:\n  ".
		 "account amigo EMAILADDRESS PASSWORD\n(filling in ".
		 "EMAILADDRESS and PASSWORD, of course).\n";
		exit 1;
	}
	my $res;
	my $cookie_jar = HTTP::Cookies->new;
	my $base = "http://www.amigo.co.il/html";
	# If we get an HTTP error, we are going to retry 4 times with short
	# sleep intervals; since we expect the URLs to work, we'll retry
	# on any type of error - however strange. In the future, if the
        # retries don't help (e.g., in case of a longer-term problem), the
        # message should be queued for later delivery.
	my $ntries=0;
	while(1){
	if($ntries>=4){
		print STDERR "Failed $ntries login attempts - giving up.\n";
		exit 3;
		last; # not reached
	};
	# sleep a little until the next try
	sleep(30*$ntries*$ntries) if ($ntries>0);
	$ntries++;
	# Log in. We found the script we need to call, and the form parameters
	# we need to set, in the $base/login/login.asp page.
        $req = new HTTP::Request POST => "$base/login/check_login.asp";
	$req->content_type('application/x-www-form-urlencoded');
	$req->content("user_username=".uri_escape($AMIGO_USER, '^A-Za-z')."&".
		      "user_psw=".uri_escape($AMIGO_PASSWORD, '^A-Za-z'));
	$req->header('Accept' => 'text/html');

	$res = $ua->request($req);
	$cookie_jar->extract_cookies($res);

	# Successful login results in redirection to sending_frame.asp, and
	# with cookies (saved above) needed for the final, SMS sending form.
	if ($res->code==302 && $res->header('location') eq "../sending/sending_frame.asp") {
		if($ntries>1){
			print STDERR "Success on attempt #$ntries\n";
		}
		last; # stop retrying to log in
	} else {
		# If this is a known, permanent, error (e.g., wrong password),
		# then we exit. Otherwise we take this as a transient error
		# and try again.
		if($res->code==200){
			if($res->as_string =~ /הזנת נתונים לא נכונים נסה שוב/){
				print STDERR "Failed login into Amigo: bad user/password.\n";
				exit 1;
			}
		}
		print STDERR "Error: " . $res->status_line . "\n";
		# go on to try again
	}
	}

	# now that we have session information (in cookie jar), send the
	# sms.
	
	my $mymessage=$message;
	# TODO: check if we need to change newlines, empty messages, or
	# fix other similar problems.
	# TODO: does Amigo support Hebrew? Do we need to do anything special
	# about it?

	$ntries=0;
	while(1){
	if($ntries>=4){
		print STDERR "Failed $ntries message sends - giving up.\n";
		exit 5;
		last; # not reached
	};
	# sleep a little until the next try
	sleep(30*$ntries*$ntries) if ($ntries>0);
	$ntries++;
        $req = new HTTP::Request POST => "$base/sending/sending.asp";
	$req->content_type('application/x-www-form-urlencoded');
	# NOTE: 1. we currently don't use Amigo's feature to send the same
	# message to up-to-6 phones. In the future, we can add such a
	# capability to sendsms, but it doesn't seem so important..
	# 2. the phone_1...phone_6, redir and counter fields also present in
	# $base/sending/sending_form.asp are ignored.
	# TODO: what to do about sender num? Currently I send "123" :)
	$req->content("from=".uri_escape($sender, "^A-Za-z")."&".
		      "sender_num=123&".
		      "amigo1=57".uri_escape(substr($phonenum,3), "^0-9A-Za-z")."&".
		      "amigo2=57&amigo3=57&amigo4=57&amigo5=57&amigo6=57&".
		      "message=".uri_escape($mymessage, "^A-Za-z"));
	$req->header('Accept' => 'text/html');
	$cookie_jar->add_cookie_header($req);
	$res = $ua->request($req);

# just trying...
#        $req = new HTTP::Request GET => ("$base/sending/".$res->header('location'));
#	$cookie_jar->add_cookie_header($req);
#	$res = $ua->request($req);
#	print $res->as_string;
	if ($res->code==302 && $res->header('location') =~ /actions\.asp\?amigo1msg=1/) {
		print STDERR "Sent successfully.\n";
		last;
        } else {
		# I don't know what this error means, or why it happens.
		# let's hope a retry will work...
		print STDERR "Sending the message failed with an unknown error... Retrying...\n";
		next;
	}
	}
############################################################################
} else {
	print STDERR "Sorry, unrecognized cellphone number $phonenum.\n";
	print STDERR "Currently, recognized numbers must begin with:\n";
	print STDERR "   Cellcom:   052, 053, 058, 064, or 065\n";
	print STDERR "   Orange:    054, 055, 066 or 067\n";
	print STDERR "   Pelephone: 050, 051, 056 or 068\n";
	print STDERR "   Amigo:     057\n";
	print STDERR "followed by exactly 6 digits, or new-style numbers:\n";
	print STDERR "   050, 052, 054 or 057 followed by 7 digits.\n";
	print STDERR "Spaces and hyphens are ignored.\n";
	exit 2;
}

sub sixtoseven {
  $_ = shift;
  s/-//g;
  s/^050/0505/;
  s/^051/0507/;
  s/^052/0522/;
  s/^053/0523/;
  s/^054/0544/;
  s/^055/0545/;
  s/^056/0506/;
  s/^057/0577/;
  s/^058/0528/;
  s/^059/0599/;
  s/^060/060/;
  s/^061/061/;
  s/^062/062/;
  s/^063/063/;
  s/^064/0524/;
  s/^065/0525/;
  s/^066/0546/;
  s/^067/0547/;
  s/^068/0508/;
  return $_
}
1;
