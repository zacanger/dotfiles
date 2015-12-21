#! /usr/bin/perl -Tw

$crlf="\015\012";
$pixel=pack("C*",qw(71 73 70 56 57 97 1 0 1 0 128 0 0 255 255 255 0 0 0 33 249 4 1 0 0 0 0 44 0 0 0 0 1 0 1 0 0 2 2 68 1 0 59));

while (<STDIN>)
{
	chop;chop;
#	print "$_\n";
	if ($_ eq '') { last; }
}
print "HTTP/1.1 200 OK$crlf";
print "Content-type: image/gif$crlf";
print "Accept-ranges: bytes$crlf";
print "Content-length: 43$crlf$crlf";
print $pixel;

exit(0);
