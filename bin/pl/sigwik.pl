 #!/usr/bin/perl
 use CGI':all';path_info=~/\w+/;$_='<div class="sb">'.`ls -1t|head`.'</div>'.`grep -l $& *|fmt`.h1($&).
 escapeHTML$t=param(2)||`dd<$&`;open F,">$&";print F$t;s/htt\S+|([A-Z]\w+){2,}/a{href,$&},$&/eg;s/
 /br/eg;print header,start_html(-style=>{-src=>'./s.css'})."$_<form>",submit,textarea 2,$t,9,70

