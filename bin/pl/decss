#!/usr/bin/perl

# DeCSS v 0.06 -- a utility for stripping Cascading Style Sheet (CSS)
# information from an HTML page

# Copyright 2000, Mr. Bad of Pigdog Journal (http://www.pigdog.org/).
# All Rights Reserved.

# This software is distributed under the Artistic License, which should have
# come with this file. Please distribute this software far and wide.
# The original version can always be found on the World Wide Web at:
#
#      http://www.pigdog.org/decss/

# THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

use Getopt::Std;
use strict;			# Choosy software use's strict!

my($USAGE) = <<"END_OF_USAGE";
DeCSS 0.06: a utility to strip Cascading Style Sheets (CSS) tags 
            from HTML documents

USAGE: DeCSS [-h] [-i input file] [-o output file]

options:
	-h		print this help message
        -i input file	input file to strip (default: standard input)
        -o output file	place to put the output (default: standard output)

END_OF_USAGE

my(%options);
local(*IN, *OUT);

getopts("hi:o:", \%options);

if (exists $options{h}) {
    print $USAGE;
    exit(0);
}

if (exists $options{i}) {
    open(IN, "<$options{i}") or die "Can't open $options{i}: $!\n";
} else {
    open(IN, "<&STDIN") or die "Can't open STDIN: $!\n";
}

if (exists $options{o}) {
    open(OUT, ">$options{o}") or die "Can't open $options{o}: $!\n";
} else {
    open(OUT, ">&STDOUT") or die "Can't open STDOUT: $!\n";
}

decssify(*IN, *OUT);

close(IN);
close(OUT);

sub decssify {
    local(*IN, *OUT) = @_;

    # Yeah, like -you- never slurp in entire files at a time.

    select(IN); undef $/;

    my($content) = <IN>;

    $content =~ s%<link.*?rel=\"stylesheet\".*?>%%mg; # Strip stylesheet links
    $content =~ s%<style>.*?</style>%%mg; # Strip <style> blocks
    $content =~ s%style=\".*?\"%%mg; # Strip style attributes
    $content =~ s%class=\".*?\"%%mg; # Strip class attributes
    $content =~ s%id=\".*?\"%%mg; # Strip id attributes

    print OUT $content;
}

__END__


=head1 NAME

DeCSS - A utility to strip Cascading Style Sheet (CSS) information from a Web page.

=head1 SYNOPSIS

DeCSS -i my_file.html -o my_file_no_css.html

=head1 DESCRIPTION

DeCSS is a utility program to strip Cascading Style Sheet (CSS)
information from a Web page. For a given input HTML file, it removes
the following type of HTML code:

=over 4

=item E<lt>styleE<gt> tags

=item E<lt>linkE<gt> tags that are for CSS stylesheets

=item C<class> attributes

=item C<style> attributes

=item C<id> attributes

=back

That's all it does. It has no relationship whatsoever to encryption,
copy protection, movies, software freedom, oppressive industry
cartels, Web site witch hunts, or any other bad things that could get
you in trouble. Please feel free to redistribute it as much as possible,
preferably on your Web site.

=head1 AUTHOR

Mister Bad <mr.bad@pigdog.org>

=head1 SEE ALSO

=over 4

=item W3 Cascading Style Sheets (CSS) site

http://www.w3.org/Style/CSS/

=back

=head1 VERSION HISTORY

=over 4

=item 0.06

Repackaged software, including mirroring utilities and a FAQ.

=item 0.05

Initial version.

=back

=cut

# Local Variables: #
# mode: perl #
# End: #

