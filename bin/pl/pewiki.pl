#!/usr/bin/perl -0777itextarea
use CGI':all';$;='<a href=?';$i='<input type';$$_=param$_ for e,t,f;$t&&open(F
,">$f"),print F$t;sub r{open F,pop;escapeHTML<F>}print header,$e?start_form."
<$^I name=t>${\r$e}</$^I>$i=hidden name=f value=$e>".submit:do{$_="$f</h1>".r(
$f).p grep r($_)=~$f,<*>;s!{(.+?)}!ul$1!egs;s!http:\S+!a{-href,$&},$&!eg;s![\r
]{4,}!p!eg;s!^@ !<li>!gm; s!([A-Z][a-z]+){2,}!$;@{[-f$&?f:e]}=$&>$&</a>!g;
"<h1>$;e=$f>?</a>:$_"}

