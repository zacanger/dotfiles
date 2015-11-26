#!/usr/bin/perl -0777itextarea
use CGI":all";for(g,e,t){$$_=param$_}$g=~s!/!!g;sub o{open F,$_[0];escapeHTML<F>
}$i='><input type';$h='<a href=w?';if($t){open G,">$g";print G$t}print header,$e
?start_form."<$^I rows=9 cols=9 name=t>@{[o$e]}</$^I$i=submit$i=hidden value=$e 
name=g></form>":$h."e=$g>?</a>".(do{@n=grep(o($_)=~/$g/,glob'*');$_=h1($g).o($g)
.p.">@n";s!{!<ul>!g;s!\r?\n\r?\n!p!eg;s!http:\S+!<a href=$&>$&</a>!g;s!}!</ul>!g
;s!^@ !<li>!gm;s!([A-Z][a-z]+){2,}!$h.(-f$&?"g=$&>":"e=$&>?")."$&</a>"!eg}&&$_)

