#!/usr/bin/perl
# This is GNU software:  use is permitted -- and encouraged -- but only under the terms set forth at http://www.gnu.org/licenses/gpl.txt.
# Copyright 2002, 2003, 2006 by Scott Walters, scott@illogics.org, and contributors.
# See http://perldesignpatterns.com/?TinyWiki for more information on TinyWiki, and how to configure and use it.
# use Carp; use CGI::Carp 'fatalsToBrowser'; *Carp::longmess_heavy = *Carp::longmess;
exit if $ENV{HTTP_USER_AGENT} =~ m/Java/; # what the FUCK is it with these Java robots pounding the hell out of the site?
umask 0; my $wiki = qr{[A-Z][a-z]+[A-Z][A-Za-z]+}; my $sn = $ENV{SCRIPT_NAME}; my $rip = $ENV{REMOTE_ADDR};
do {
  sub a0 ($); sub a1 ($); sub a2 ($); sub a3($); sub a4($); our $text; our $state; our $typeface; 
  for my $x (0..4) { 
    my @rules = (sub { $text =~ m/\G([a-z0-9]+|.)/icgs ? print($1) : ($state = sub { goto DONE; }) });
    *{"a$x"} = sub ($) { splice @rules, -1, 0, $_[0]; $_[0]; }; *{"s$x"} = sub () { for my $r (@rules) { $r->() and return; } }; 
    *{"i$x"} = sub ($) { unshift @rules, $_[0]; $_[0]; };
  }
  *sb_parse = sub { local $text = "\n".$_[0]."\n"; local $state = \&s0; local $typeface; $state->() while 1; DONE: };
  # list items
  a0 sub { $text =~ m/\G(?<=\n)\* /cgs or return; print '<li> '; 1; };                     # level-one bullet: no state change
  a0 sub { $text =~ m/\G(?<=\n) *\* /cgs or return; print '<ul><li> '; $state=\&s2; 1; };  # level-two bullet from state 0
  a2 sub { $text =~ m/\G(?<=\n)\* /cgs or return; print '</ul><li> '; $state=\&s0; 1; };   # level-one bullet ends level-two 
  a2 sub { $text =~ m/\G(?<=\n)(?= *\n)/cgs or return; print '</ul>'; $state=\&s0; 1; };   # blank line ends level-two bullets
  a2 sub { $text =~ m/\G(?<=\n)( +)\*(?= )/cgs && print '<li>' };                          # level-two bullet while in l2 already
  a2 sub { $text =~ m/\G(?<=\n)( *)(?=[^* ])/cgs };                                        # stay in l2 otherwise - could print <br><pre>$1</pre> here maybe to force indentation
  # other begining of line rules
  a0 sub { $text =~ m/\G(?<=\n)-----* *\n+/cgs && print("<hr><br>") }; 
  a0 sub { $text =~ m/\G(?<=\n)(  ?)/cgs or return;
           print(qq{<table width="100%" border=0 ><tr><td width=12>&nbsp;&nbsp;</td><td bgcolor="#EEEEDD"><pre>$1}); $state=\&s1; 1; };
  a1 sub { $text =~ m/\G\n(?<=\n)(?! |(?: *\n ))/cgs or return; print("</pre></td><td width=12>&nbsp;&nbsp;</td></tr></table>"); $state=\&s0; 1; };
  a1 sub { $text =~ m/\G(\n+)/cgs or return; print($1); 1; };
  a0 a2 sub { $text =~ m/\G(?<=\n)\n*(?=\n)/cgs or return; 
             print($typeface & 0b0001 ? '</i>' : '', $typeface & 0b0010 ? '</u>' : '', $typeface & 0b0100 ? '</b>' : '', 
                   $typeface & 0b1000 ? '</tt>' : '', "\n<br><br>\n"); $typeface = 0; 1; };
  a0 sub { $text =~ m/\G\n/cgs or return; print(' '); 1; };
  a0 sub { $text =~ m{\G(?<=\n)\|\|([\w\s\,\:\-]{3,40})\|\|\s*\n+}cgs && print qq{<font size="+2"><b>$1</b></font><br><br>}; };
  # typeface
  a0 a2 sub { $text =~ m{\G(?<!:)//}cgs or return; print($typeface & 0b0001 ? '</i>' : '<i>'); $typeface ^= 0b0001; 1; };
  a0 a2 sub { $text =~ m{\G__}cgs or return; print($typeface & 0b0010 ? '</u>' : '<u>'); $typeface ^= 0b0010; 1; };
  a0 a2 sub { $text =~ m{\G\|\|}cgs or return; print($typeface & 0b0100 ? '</b>' : '<b>'); $typeface ^= 0b0100; 1; };
  a0 a2 sub { $text =~ m{\G''}cgs or return; print($typeface & 0b1000 ? '</tt>' : '<tt>'); $typeface ^= 0b1000; 1; };
  # wiki-word and wiki-word like things 
  a0 a1 a2 sub { $text =~ m/\G([A-Z][A-Za-z]+):(\S+)/cogs && print(qq{<a href="intermap.cgi?wiki=$1&word=$2">$1:$2</a>}) };
  a0 a2 sub { $text =~ m/\G(?<![#"?&A-Z])($wiki)/cogs or return; my $l = $1; (my $slink = $l) =~ s/(?<=[a-z])([A-Z])/ $1/g;
              print($alreadydone{$l} ? qq{<a href="#$l"><b>$slink</b></a>} : -f $l ? qq{<a href="$sn?$l">$slink</a>} : qq{$slink<a href="$sn?$l">+</a>}); 1; };
  a1 sub { $text =~ m/\G(?<![#"?&A-Z])($wiki)/cogs ?  print($alreadydone{$1} ? qq{<a href="#$1"><b>$1</b></a>} : -f $1 ? qq{<a href="$sn?$1">$1</a>} : $1 ) : 0; };
  # general markup
  a0 a1 a2 sub { $text =~ m/\G<%(.*?)%>/cgs or return; unlink "$word.html"; do_eval($1); print($@) if $@; 1; }; 
  a0 a1 a2 sub { $text =~ m/\GISBN\s+([0-9X-]{9,})/cgs && print qq{<a href="http://shop.bn.com/bookSearch/isbnInquiry.asp?isbn=$1">ISBN $1</a>}; };
  a0 a1 a2 sub { $text =~ m/\G(?<!")((?:(http)|(mailto)|(ftp))\:\/?\/?\S+[^.\s])/cgs && print(qq{<a href="$1">$1</a>}); };
  a1         sub { $text =~ m/\G</cgs && print($1.'&lt;') };
};

if(!caller) {
  my $in = $ENV{QUERY_STRING}; $in.='&'; read(STDIN, $in, $ENV{CONTENT_LENGTH}||0, length($in));
  map { $nam='word';s{^([a-z_]+)=}{$nam=$1;''}e; tr/+/ /; s/%(..)/pack('c',hex($1))/ge; $$nam=$_; } split/[&;]/, $in;
  $word eq 'self' and do { seek DATA, 0, 0; print "Content-type: text/plain\r\n\r\n", <DATA>; exit 0; };
  $word =~ s/((\A|\s)[a-z])/\U$1/g; $word =~ s/\s//g; $word = 'HomePage' unless $word and $word =~ m/^$wiki$/o; 
  print qq{Content-type: text/html\r\n\r\n<html>};
  $action ||= 'view'; $action = 'edit' if ! -f $word and $action ne 'save'; 
  print '<!-- '; system 'cvs', 'update', $word; print ' -->';
  if($action eq 'view') { 
    # exec 'cat', "$word.html" if -f "$word.html"; open TEE, '|-', '/usr/bin/tee', "$word.html" or die $!; select TEE;  # caching disabled; doesn't play nicely with embedded scripts that respond to eg the user agent or other things that change
  } elsif($action eq 'save') { unlink "$word.html" }
}
sub do_eval { my $wiki=$wiki; my $word=$word; my $rip=$rip; eval $_[0]; print $@ if $@; } # must be out of lexical context of the do { } block or lexicals can be corrupted!
do {
  my $origword = $word; my $origwiki = $wiki; my $origrip = $rip; 
  *sb_open = sub { $_[0] =~ m/^$origwiki$/o or die; my $fh; if(! -f $_[0] && $_[0] eq $origword) { open $fh, '>', $_[0]; } elsif( (-w _ && $_[0] eq $origword) || $_[0] =~ m/^Public/) { open $fh, '+<', $_[0] } else { open $fh, '<', $_[0] }; $fh };
  # *sb_use = sub { my $p=sb_open(@_); $_=join'',<$p>; map { do_eval("package $_[0];$_"); $@ and print $@; } m{<%(.*?)%>}gs; };
  *sb_use = sub { my $p=sb_open(@_); $_=join'',<$p>; map { do_eval($_); $@ and print $@; } m{<%(.*?)%>}gs; };
  *sb_read = sub { my $fh = sb_open(@_); my $buf = join '', readline $fh or die $!; close $fh; return $buf; };
  *sb_commit = sub { print '<!-- commit: '; system 'cvs', 'commit', '-m', $origrip, $origword; print ' -->'; sleep 3; };
  *sb_add = sub { print '<!-- add: '; system 'cvs', 'add', $origword; print ' -->'; sleep 5; };
  *sb_save = sub { $nt = shift; my $exists = -f $origword; my $f=sb_open($origword); truncate $f, length $nt; print $f $nt; $exists or sb_add(); sb_commit(); };
  *sb_listall = sub { opendir my $dir, '.' or print $! and return; sort grep m/^$origwiki$/o, (readdir $dir) };
  *sb_search = sub { grep { sb_read($_) =~ m/\Q$_[0]\E/ } sb_listall() }; # this doesn't require special permission - a "utility" AWP shoud be created to hold common routines like this XXX
  *sb_size = sub { ( $_[0] =~ m/^$origwiki$/o and -f $_[0] ) ? -s $_[0] : undef }; # i'm already letting -f through, might as well let -s through XXX
  *sb_recent = sub { map @$_, sort { $b->[1] <=> $a->[1] } map [ $_, (stat $_)[9] ], @_ ? @_ : sb_listall(); };
};
sub captcha {   # optional -- uses recaptcha.net's free service; this is called from RetroWikiHeader when $actioneq 'save'; the privatekey file emits the private key (without trailing newline) when run and has its execut bits set but not read bits
    use Socket; socket my $s, 2, 1, 6 or die $!; connect $s, scalar sockaddr_in(80, scalar inet_aton("api-verify.recaptcha.net")) or do {print $!; exit; };
    $recaptcha_response_field =~ s/ /\+/g; my $postdata = join '', 'privatekey=', `/home/httpd/privatekey`, '&remoteip=', $rip, '&challenge=', $recaptcha_challenge_field, '&response=', $recaptcha_response_field;
print "debug: sending: $recaptcha_response_field";
    syswrite $s, "POST /verify HTTP/1.0\r\nHost: api-verify.recaptcha.net\r\nContent-type: application/x-www-form-urlencoded\r\nContent-Length: " . length($postdata) . "\r\n\r\n" . $postdata; return join '', <$s>; }
sub mailscott { }  # XXX install sendmail, I guess # sub mailscott { open my $sm, '|-', '/usr/sbin/sendmail', '-t' or die $!; print $sm "From: scott\nTo: scott\nSubject: TinyWiki: $word changed\n\n$newtext" or die $!; close $sm or die $!; }
return if caller; alarm 60*4; use ops qw(:default :base_io entereval ftfile sort exit rand stat ftsize ftfile caller flock close print seek);
*describeword{CODE} or *describeword = sub { $ENV{HTTP_REFERER} =~ m/($wiki)$/; "Describe '$word' here.\n\n||See Also||\n\n* $1\n"; };
$text = -f $word ? sb_read($word) : describeword();
sb_use('RetroWikiHeader'); -f "WikiAction\u$action" and sb_use("WikiAction\u$action"); 
if($action eq 'edit') { print qq{
  <h3>Edit '$word':</h3><a href="wiki.cgi?$word">Abord Edit: Back to Word</a>
  <form method="post" action="$sn?$word">
    <textarea name="newtext" cols="80" rows="24" wrap="virtual">$text</textarea><br> <!-- Password: <input type="password" name="password"><br> --> $form_extra
    <input type="hidden" name="action" value="save"><input type="submit" value="Save Changes">
  </form>};
} elsif($action eq 'save') {
  $newtext =~ s/\015//g; $newtext .= "\n" unless $newtext =~ m/\n$/; sb_save($newtext); mailscott();
  print qq{<h3>$word Saved.</h3>\n}; $text = sb_read($word); sb_parse($text);
} else { sb_parse($text); }
sb_use('RetroWikiFooter'); 
__DATA__
# states: 0 - flowing text; 1 - preformatted text; 2 - list items; 3 - inline image data
#
