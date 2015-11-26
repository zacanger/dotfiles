#!/usr/bin/perl
use CGI':all';path_info=~/\w+/;$_=`grep -l $& *`.h1($&).escapeHTML$t=param(2)
||`dd<$&`;open F,">$&";print F$t;s/htt\S+|([A-Z]\w+){2,}/a{href,$&},$&/eg;s/
/br/eg;print header,"$_<form>",submit,textarea 2,$t,9,70

