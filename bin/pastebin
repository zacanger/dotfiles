#!/usr/bin/perl -W
use strict;
local $/;
my $data = <>;
use LWP;
use HTTP::Request::Common qw(POST);
my $ua = LWP::UserAgent->new(env_proxy=>1);
my $req = POST 'http://pastebin.com/pastebin.php',[
    parent_pid => "",
    expiry => "d",
    poster => "$ENV{USER}",
    email => "",
    format => "text",
    paste => "Send",
    code2 => $data];
print $ua->request($req)->header("Location"), "\n";
