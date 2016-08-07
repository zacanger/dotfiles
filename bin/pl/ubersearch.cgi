#!/usr/bin/env perl
use strict;
use CGI qw/:standard/;
use URI::Escape;

my $q = param("q");
my $e = param("e");
die "Must specify q and e" unless $q and $e;
$q = uri_escape($q);

my $dest;
if ($e eq "google") {
	$dest = "http://www.google.com/search?q=$q&num=200";
} elsif ($e eq "alltheweb") {
	$dest = "http://www.alltheweb.com/search?q=$q&num=200";
} elsif ($e eq "gigablast") {
	$dest = "http://www.gigablast.com/search?q=$q&n=50";
} elsif ($e eq "yahoo") {
	$dest = "http://new.search.yahoo.com/search?p=$q&n=200";
} elsif ($e eq "googlegroups") {
	$dest = "http://groups.google.com/groups?q=$q&num=200";
} elsif ($e eq "messageid") {
	$q =~ s/^%3C//;
	$q =~ s/%3E$//;
	$dest = "http://groups.google.com/groups?selm=$q";
} elsif ($e eq "dictionary") {
	$dest = "http://www.dictionary.com/search?q=$q&db=%2A";
} elsif ($e eq "imdb") {
	$dest = "http://www.imdb.com/M/title-substring?title=$q&type=fuzzy";
} elsif ($e eq "freshmeat") {
	$dest = "http://freshmeat.net/search/?q=$q";
} elsif ($e eq "ukclibrary") {
	$dest = "http://plato.ukc.ac.uk/cgi-bin/kform?ktitle=$q&enqtype=AUTHOR-TITLE&enqpara1=query&authpara1=";
} elsif ($e eq "ukcopac") {
	$dest = "http://opac.ukc.ac.uk/cgi-bin/Pwebrecon.cgi?DB=local&Search_Arg=$q&SL=None&Search_Code=TKEY&CNT=500&HIST=1";
} elsif ($e eq "oed") {
	$dest = "http://dictionary.oed.com.chain.kent.ac.uk/cgi/findword?query_type=word&queryword=$q&find=find";
} elsif ($e eq "oxref") {
	$dest = "http://www.oxfordreference.com.chain.kent.ac.uk/views/SEARCH_RESULTS.html?q=$q";
} elsif ($e eq "sus") {
	$dest = "http://www.opengroup.org/cgi-bin/kman2?value=$q";
} elsif ($e eq "freebsd") {
	# Remember to update the version in this when they release.
	$dest = "http://www.freebsd.org/cgi/man.cgi?query=$q&apropos=0&sektion=0&manpath=FreeBSD+5.0-current&format=html";
} elsif ($e eq "openbsd") {
	$dest = "http://www.openbsd.org/cgi-bin/man.cgi?query=$q&apropos=0&sektion=0&manpath=OpenBSD+Current&arch=i386&format=html";
} elsif ($e eq "netbsd") {
	$dest = "http://netbsd.gw.com/cgi-bin/man-cgi?$q++NetBSD-current";
} elsif ($e eq "foldoc") {
	$dest = "http://foldoc.doc.ic.ac.uk/foldoc/foldoc.cgi?query=$q&action=Search";
} elsif ($e eq "citeseer") {
	$dest = "http://citeseer.ist.psu.edu/cs?q=$q";
} else {
	die "Unknown engine";
}
print redirect($dest);

