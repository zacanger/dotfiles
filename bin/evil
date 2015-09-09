#!/usr/bin/perl
$SIG{$_}=q/IGNORE/ for qw/INT QUIT TERM TSTP HUP/;
my $host = `hostname`;
$host =~ s/\..*//s;
my $me = `whoami`;
$me =~ s/[\r\n]//g;
my $prompt =  "$me\@$host";
print "$prompt:~\$ ";
while (1){$_=<>;my $x; m#([/_~+a-zA-Z0-9-]+)# and $x = "bash: $1: command not found\n"; print "${x}$prompt:~\$ "}
