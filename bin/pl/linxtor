#!/usr/bin/perl
use strict;
use warnings;

=head1 NAME

linkextor -- extract particular links from HTML documents

=head1 SYNOPSIS

F<linkextor>
S<B<[ -b baseurl ]>>
S<B<[ -f filter ]>>
S<B<[ files and urls ]>>

=head1 DESCRIPTION

C<linkextor> prints links found in given HTML documents, filtered by any given expressions. If no files are specified on the command line, the input document is read from STDIN. You can specify URLs on the command line; they will be downloaded and parsed transparently.

By default, no links are filtered, so the output will include references to every external resource found in the file such as stylesheets, external scripts, images, other documents, etc.

After considering criteria, all matching links will be printed to STDOUT. You could pipe them to C<wget -i -> to mass download them, or to C<while read url ; do ... ; done> or C<xargs> to process them further, or do anything else you can do with a list of links.

=head1 ARGUMENTS

=over 4

=item B<-h>, B<--help>

See a synopsis.

=item B<--man>

Browse the manpage.

=back

=head1 OPTIONS

=over 4

=item B<-b>, B<--base>

Sets base URL to use for relative links in the file(s).

This only applies to local files and input read from STDIN. When parsing documents retrieved from a URL, the source URL is always the base URL assumed for that document.

=item B<-f>, B<--filter>

Defines a filter.

If no filter has been specified, B<all> external links will be returned. This includes links to CSS and Javascript files specified in C<E<lt>linkE<gt>> elements, image links specified in C<E<lt>imgE<gt>> elements, and so on.

If one or more filters have been specified, only links conforming to any of the specified criteria will be output.

Filters take the form C<tagname:attribute:regex>. C<tagname> specifies which tag this filter will allow. C<attribute> specifies which attribute of the allowed tags will be considered. C<regex> specifies a pattern which candidate links must match. You can leave any of the criteria empty. For empty criteria on the right-hand side of the specification, you can even omit the colon.

Eg, C<-f 'a:href:\.mp3$'> will only extract links from the C<href=> attributes in the document's C<E<lt>aE<gt>> tags which end with C<.mp3>. Since C<E<lt>aE<gt>> tags can only contain links in their C<href=> attribute you can shorten that to C<-f 'a::\.mp3$'>. If you wanted any and all links from C<E<lt>aE<gt>> tags, you could use C<-f a::>, where both the attribute and regex component are empty, or just C<-f a>: because both components to the right are empty, you can leave out the colons entirely. Likewise, you could use C<-f img> to extract all images.

=back

=head1 BUGS

None currently known.

=head1 SEE ALSO

=over 4

=item * L<perlre>

=item * L<xargs(1)>

=item * L<wget(1)>

=back

=head1 COPYRIGHT

Aristotle Pagaltzis

=head1 LICENCE

This script is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

use Getopt::Long;
use Pod::Usage;
use HTML::LinkExtor;
use URI;
use LWP::UserAgent;

my %filter;

sub valid_link {
	my ( $tag, $attr, $value ) = @_;
	return 1 if not %filter;
	my $attr_filter = $filter{ $tag } || $filter{ '' } || return;
	my $patterns = $attr_filter->{ $attr } || $attr_filter->{ '' } || return;
	return 1 if not @$patterns;
	return 1 if grep $value =~ /$_/, @$patterns;
	return;
}

GetOptions(
	'h|help'     => sub { pod2usage( -verbose => 1 ) },
	'man'        => sub { pod2usage( -verbose => 2 ) },
	'b|base=s'   => ( \my $opt_base ),
	'f|filter=s' => ( \my @opt_filter ),
) or pod2usage();

for( @opt_filter ) {
	my ( $tag, $attr, $pattern ) = split m!:!, $_, 3;
	$attr = '' unless defined $attr;
	push @{ $filter{ $tag }{ $attr } }, defined( $pattern ) ? qr/$pattern/ : ();
}

my $base;

my $p = HTML::LinkExtor->new( sub {
	my $element = shift @_;
	while( my ( $attr, $value ) = splice @_, 0, 2 ) {
		my $url = URI->new_abs( $value, $base )->as_string;
		print $url, "\n" if valid_link( $element, $attr, $url );
	}
} );

my $ua = LWP::UserAgent->new();

if ( @ARGV ) {
	for( @ARGV ) {
		if( -r ) {
			$base = $opt_base;
			$p->parse_file( $_ )
				or warn( "Couldn't parse $_\n" ), next;
		}
		else {
			$base = $_;
			$ua->get( $_, ':content_cb' => sub { $p->parse( shift ) or die; } )
				or warn( "Could neither open nor download $_\n" ), next;
			$p->eof();
		}
	}
}
else {
	$base = $opt_base;
	$p->parse_file( \*STDIN );
}