#!/usr/bin/perl -w
use strict;
use sigtrap;

# Copyright Philipp L. Wesche 2003
# Released under the General Public License,
# which can be found at
# http://www.gnu.org/copyleft

open IN, "bookmarks.html" || die "Opening bookmarks.html in this directory failed.\n";
my @lines = <IN>;
close IN;

# next two for loops: get rid of the non-relevant lines

for (my $i = 0; $i < @lines; $i++) {
	unless ($lines[$i] =~ /\<A HREF|\<H3/) {
		splice (@lines, $i, 1);
	}
}

for (my $i = 0; $i < @lines; $i++) {
	if ($lines[$i] =~ /DL\>/) {
		splice (@lines, $i, 1);	
	}
}

# remove some header info
splice (@lines, 0, 4);


my $line_array_length = @lines;

my $ident = 0;

my $linenum = 0;

my @name = ("Home");
my @link;
&generations(0, 0, $ident, \@name, \@link);


sub generations {
	# make it more readable
	my $depth = $_[0];
	my $startline = $_[1];

	my $filenum = $_[2];

	my $name_list_pointer;
	my @names;
	my @newnames;
	if (defined($_[3])) {
		$name_list_pointer = $_[3];
		@names = @$name_list_pointer;
		@newnames = @$name_list_pointer;
	}

	my $href_list_pointer;
	my @hrefs;
	my @newhrefs;
	if (defined($_[4])) {
		$href_list_pointer = $_[4];
		@hrefs = @$href_list_pointer;
		@newhrefs = @$href_list_pointer;
		push (@newhrefs, "$filenum.html");
	}

	++$ident;

	my @links_thislevel;
	my @urls_thislevel;

	my $aktuell = 0;	

	while (defined($lines[$linenum])) {
		my @chars = split (//, $lines[$linenum]);
		unless (defined($chars[0])) {
			last;
		}
		if ($depth > 0) {
			unless ($lines[$linenum] =~ /^ {$depth}/) {
				last;
			}
		}

		if ($chars[$depth] =~ /\</) {
			push @newnames, (split /\"\>|\<\//, $lines[$linenum])[1];
		}

		if ($chars[$depth] eq " ") {
			$urls_thislevel[$aktuell] = "$ident.html";

			&generations( ($depth + 4), $linenum, $ident, \@newnames, \@newhrefs);
			pop (@newnames);
		} else {
			++$aktuell;
			if ($lines[$linenum] =~ /A HREF/) {
				push @links_thislevel, (split /\"\>|\<\//, $lines[$linenum])[1];
				$urls_thislevel[$aktuell] = (split /\"/, $lines[$linenum])[1];
			} else {
				push @links_thislevel, (split /\"\>|\<\//, $lines[$linenum])[1]." >";
			}
			++$linenum;
		}
	}

	shift (@hrefs);

	open (OUT, ">$filenum.html");
	print OUT '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><html><head><meta http-equiv="content-type" content="text/html; charset=ISO-8859-1"><title>'.$names[@names - 1].'</title><style type="text/css"><!-- p.mn {font-size:14pt; font-weight:bold; margin:30px;}//--></style></head><body>';

	for (my $indaxe = 0; $indaxe < @links_thislevel; ++$indaxe) {
		if (defined($urls_thislevel[$indaxe + 1])) {
			print OUT '<p class=mn><a href="'.$urls_thislevel[$indaxe + 1].'">'.$links_thislevel[$indaxe].'</a></p>';
		} else {
			print OUT '<p class=mn>'.$links_thislevel[$indaxe].'</p>';
		}
	}

	print OUT '<p>You are here: ';
	for (my $cur_depth = 0; $cur_depth < @hrefs; ++$cur_depth) {
		print OUT '<a href="'.$hrefs[$cur_depth].'">'.$names[$cur_depth].'</a> -> ';
	}
	print OUT $names[@names - 1];
	print OUT "</p>";

	print OUT '</body></html>';
	close OUT;
	++$ident;
}
