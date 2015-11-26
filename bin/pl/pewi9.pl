#!/usr/bin/perl -w
use CGI qw(:all);$g=param"g";$e=param"e";$p=param"p";$g=~s!/!!g;$h='<a href=w?'
;$i='><input type';sub o{open(F,$_[0]);return escapeHTML(join'',<F>);};($g&&$p)
and do{open(G,">$g");print G$p;};print"Content-Type:text/html\n\n".($g and do{
for$s(glob'*'){$n.="$s "if(o($s)=~/$g/)};$_="$g</h1>".o($g)."\n\n>$n";s!\r!!g;s
!{!<ul>!g;s!^@ !<li>!gm;s!}!</ul>!g;s!(http:[^<>"\s]+)!<a href=$1>$1</a>!gx;s!
\n!<p>!g;s!(([A-Z][a-z]+){2,})!$h.(-f$1?"g=$1>$1</a>":"e=$1>?</a>$1")!eg;}and"
<h1>${h}e=$g>?</a>:".$_).($e and"<form action=w method=POST><textarea cols=50 
rows=8 name=p>".o($e)."</textarea$i=hidden name=g value=$e$i=submit></form>");

