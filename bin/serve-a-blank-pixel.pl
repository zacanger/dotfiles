#!/usr/bin/perl

use IO::Socket::INET;

$crlf="\015\012";
$pixel=pack("C*",qw(71 73 70 56 57 97 1 0 1 0 128 0 0 255 255 255 0 0 0 33 249 4 1 0 0 0 0 44 0 0 0 0 1 0 1 0 0 2 2 68 1 0 59));

$sock = new IO::Socket::INET (  LocalHost => '0.0.0.0',
LocalPort => '8888',
Proto => 'tcp',
Listen => 30,
Reuse => 1);

if (!defined($sock)) {
print "error : cannot bind : $! exit\n";
exit(1);
}

while ($new_sock = $sock->accept()) {
while (<$new_sock>) {
chop;chop;
#		print "$_\n";
if ($_ eq '') { last; }
}
print $new_sock "HTTP/1.1 200 OK$crlf";
print $new_sock "Content-type: image/gif$crlf";
print $new_sock "Accept-ranges: bytes$crlf";
print $new_sock "Content-length: 43$crlf$crlf";
print $new_sock $pixel;
shutdown($new_sock,2);
undef($new_sock);
}

close($sock);
exit(0);
