 #!/usr/bin/perl
 use CGI':all';$$_=param$_ for x,t;$z=($t&&"+>").$x;open z;print z$t
 if$t;$_=escapeHTML($t||join"",<z>);s/([A-Z]\w+){2,}/v$&/ge;print
 header,h1($x),pre($_,map{"\n".v$_}grep{open
 _;grep/$x/,<_>}<*>),start_form,textarea(t),hidden(x,$x),submit,end_form;sub
 v{a{href,url."?x=@_"},@_}

