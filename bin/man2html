#!/usr/bin/perl
##---------------------------------------------------------------------------##
##  File:
##      @(#) man2html 1.2 97/08/12 12:57:30 @(#)
##	$Id: man2html,v 1.23 2015/07/08 09:25:09 tom Exp $
##  Authors:
##      Earl Hood, ehood@medusa.acs.uci.edu
##	Thomas E. Dickey (for ncurses and other programs)
##  Description:
##      man2html is a Perl program to convert formatted nroff output
##	to HTML.
##
##	Recommend command-line options based on platform:
##
##	Platform		Options
##	---------------------------------------------------------------------
##	c2mp			<None, the defaults should be okay>
##	hp9000s700/800		-leftm 1 -topm 8
##	sun4			-sun
##	---------------------------------------------------------------------
##
##---------------------------------------------------------------------------##
##  Copyright 2001-2014,2015	Thomas E. Dickey
##  Copyright (C) 1995-1997	Earl Hood, ehood@medusa.acs.uci.edu
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program; if not, write to the Free Software
##  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
##  02111-1307, USA
##---------------------------------------------------------------------------##

package Man2Html;

# use strict;
use strict 'refs';    # ok
use strict 'subs';    # ok

#use strict 'vars'; # err
use warnings;

use Getopt::Long;

our $PROG = $0;
$PROG =~ s/.*\///;
our $VERSION = "3.1";

## Input and output filehandles
our $InFH  = \*STDIN;
our $OutFH = \*STDOUT;

## Backspace character:  Used in overstriking detection
our $bs;    # appease "use strict"
*bs = \"\b";    # ...but set all/any "bs" variables

##	Hash of section titles and their HTML tag wrapper.
##	This list allows customization of what HTML tag is used for
##	a given section head.
##
##	The section title can be a regular expression.  Therefore, one must
##	be careful about quoting special characters.
##
our %SectionHead = (

    '\S.*OPTIONS.*'         => '<H2>',
    'AUTHORS?'              => '<H2>',
    'BUGS'                  => '<H2>',
    'COMPATIBILITY'         => '<H2>',
    'DEPENDENCIES'          => '<H2>',
    'DESCRIPTION'           => '<H2>',
    'DIAGNOSTICS'           => '<H2>',
    'ENVIRONMENT'           => '<H2>',
    'ERRORS'                => '<H2>',
    'EXAMPLES'              => '<H2>',
    'EXTERNAL INFLUENCES'   => '<H2>',
    'FILES'                 => '<H2>',
    'LIMITATIONS'           => '<H2>',
    'NAME'                  => '<H2>',
    'NOTES?'                => '<H2>',
    'OPTIONS'               => '<H2>',
    'REFERENCES'            => '<H2>',
    'RETURN VALUE'          => '<H2>',
    'SECTION.*:'            => '<H2>',
    'SEE ALSO'              => '<H2>',
    'STANDARDS CONFORMANCE' => '<H2>',
    'STYLE CONVENTION'      => '<H2>',
    'SYNOPSIS'              => '<H2>',
    'SYNTAX'                => '<H2>',
    'WARNINGS'              => '<H2>',
    '\s+Section.*:'         => '<H3>',

);

## Fallback tag if above is not found
our $HeadFallback = '<H2>';
our $SSecFallback = '<H3>';

## Other globals

our %Aliases;    # link to a different manpage, mapping from key to value
our %Externs;    # suppress HREF if key corresponding to manpage exists
our $Bare     = 0;      # Skip printing HTML head/foot flag
our $BTag     = 'B';    # Overstrike tag
our $CgiUrl   = '';     # CGI URL expression
our $Compress = 0;      # Do blank line compression flag
our $K        = 0;      # Do keyword search processing flag
our $NoDepage = 0;      # Do not strip page information
our $NoHeads  = 0;      # Do no header detection flag
our $SeeAlso  = 0;      # Do only SEE ALSO xrefs flag
our $Solaris  = 0;      # Solaris keyword search processing flag
our $Sun      = 0;      # Headers not overstruck flag
our $Toc      = 0;      # IDs not in HTML::Toc format
our $Title    = '';     # Title
our $UTag     = 'I';    # Underline tag
our $ftsz     = 7;      # Bottom margin size
our $hdsz     = 7;      # Top margin size
our $leftm    = '';     # Left margin pad
our $leftmsz  = 0;      # Left margin size
our $ssecm    = '';     # subsection pad
our $ssecmsz  = 3;      # subsection size
our $pgsz     = 66;     # Size of page size
our $txsz     = 52;     # Text body length size
our $oldc     = "";
our $sec_sz;
our @index;

## Options

our (
    $opt_aliases, $opt_bare,      $opt_belem,    $opt_botm,
    $opt_cgiurl,  $opt_cgiurlexp, $opt_compress, $opt_externs,
    $opt_headmap, $opt_help,      $opt_index,    $opt_k,
    $opt_leftm,   $opt_nodepage,  $opt_noheads,  $opt_pgsize,
    $opt_seealso, $opt_ssecm,     $opt_solaris,  $opt_sun,
    $opt_title,   $opt_toc,       $opt_topm,     $opt_uelem
);

#############################################################################
##	Subroutines
#############################################################################

sub index_name($) {
    my $value = shift;
    if ($opt_index) {
        my $name = $value;
        $name =~ s/<H\d>//;
        $name =~ s/<\/H\d>//;
        $name =~ s/ /-/g;
        $name =~ s/[^[:alnum:]-]/_/g;
        my $head = lc $value;
        $head =~ s/^<//;
        $head =~ s/>.*//;
        $name = "$head-$name";
        $value =~ s/<\/H/<\/a><\/H/;
        $value =~ s/(<H\d)/$1 id="$name-toc"/ if $Toc;
        $value =~ s/>/><a name="$name">/;
    }
    return $value;
}

sub do_it() {

    ##	Define while loop and then evaluate it when used.  The reason
    ##	is to avoid the regular expression reevaluation in the
    ##	section head detection code.

    my $doitcode = <<'EndOfDoItCode';

    my($line, $tmp, $i, $head, $preindent, $see_also, $do, $newc);

    $see_also = !$SeeAlso;
    $newc = "";
    LOOP: while(!eof($InFH)) {
	$blank = 0;
	for ($i=0; $i < $hdsz; $i++) {
	    last LOOP  unless defined($_ = <$InFH>);
	}
	for ($i=0; $i < $txsz; $i++) {
	    last LOOP  unless defined($_ = <$InFH>);

	    ## Check if compress consecutive blank lines
	    if ($Compress and !/\S/) {
		if ($blank) { next; } else { $blank = 1; }
	    } else {
		$blank = 0;
	    }

	    ## Try to check if line space is needed at page boundaries ##
	    if (!$NoDepage && ($i==0 || $i==($txsz-1)) && !/^\s*$/) {
		/^(\s*)/;  $tmp = length($1);
		if ($do) {
		    if ($tmp < $preindent) { print $OutFH "\n"; }
		} else {
		    $do = 1;
		}
		$preindent = $tmp;
	    } else {
		$do = 0;  $preindent = 0;
	    }

	    ## Interpret line
	    $line = $_;
	    $oldc = $newc;
	    $newc = entitize(\$_);	# Convert [$<>] to entity references

	    ## Check for 'SEE ALSO' link only
	    if (!$see_also && $CgiUrl && $SeeAlso) {
		($tmp = $line) =~ s/.\010//go;
		if ($tmp =~ /^\s*SEE\s+ALSO\s*$/o) { $see_also = 1; }
		else { $see_also = 0; }
	    }

	    ## Create anchor links for manpage references
	    s/((((.\010)+)?[\+_\.\w-])+\(((.\010)+)?
	      \d((.\010)+)?\w?\))
	     /make_xref($1)
	     /geox  if $see_also;

	    ## Emphasize underlined words
	    # s/((_\010[^_])+[\.\(\)_]?(_\010[^_])+\)?)/emphasize($1)/oge;
	    # s/((_\010[^_])+([\.\(\)_]?(_\010[^_])+)?)/emphasize($1)/oge;
	    #
	    # The previous expressions were trying to be clever about
	    # detecting underlined text which contain non-alphanumeric
	    # characters.  nroff will not underline non-alphanumeric
	    # characters in an underlined phrase, and the above was trying
	    # to detect that.  It does not work all the time, and it
	    # screws up other text, so a simplified expression is used.

	    s/((_\010[^_])+)/emphasize($1)/oge;

	    $secth = 0;
	    ## Check for strong text and headings
	    if ($Sun || /.\010./o) {
		if (!$NoHeads and
		    /^([ ]{$leftmsz,$leftmsz}|[ ]{$sec_sz,$sec_sz})
		      ((.\010.)|[[:punct:]])
		      ((.\010.)|[[:punct:][:space:]])+
		      ((.\010.)|[[:punct:]])
		      [\r\n]+$/ox ) {
		    $line =~ s/.\010//go;
		    $secth = 1;
		    if ( $ssecm ne "" and /^$leftm$ssecm.*$/ ) {
		        $tmp = $SSecFallback;
		    } else {
		        $tmp = $HeadFallback;
		    }
EndOfDoItCode

    ##  Create switch statement for detecting a heading
    ##
    $doitcode .= "HEADSW: {\n";
    foreach my $head ( keys %SectionHead ) {
        $doitcode .= join( "",
            "\$tmp = '$SectionHead{$head}', ",
            "\$secth = 1, last HEADSW  ",
            "if \$line =~ /^$leftm$head/o;\n" );
    }
    $doitcode .= "}\n";

    ##  Rest of routine
    ##
    $doitcode .= <<'EndOfDoItCode';
		    if ($secth) {
			chop $line;
			$line =~ s/^\s+//;
			$_ = $tmp . $line . $tmp;
			s%<([^>]*)>$%</$1>%;
			if ( $opt_index ) {
			    $_ = &index_name($_);
			    $index[$#index + 1] = $_;
			}
			$_ = "\n</PRE>\n" . $_ . "<PRE>\n";
		    } else {
			s/(((.\010)+.)+)/strongize($1)/oge;
		    }
		} else {
		    $line =~ s/.\010//go;
		    s/(((.\010)+.)+)/strongize($1)/oge;
		}
	    }
	    print $OutFH $_;
	}

	for ($i=0; $i < $ftsz; $i++) {
	    last LOOP  unless defined($_ = <$InFH>);
	}
    }
EndOfDoItCode

    ##	Perform processing.

    printhead() unless $Bare;
    print $OutFH "<PRE>\n";
    eval $doitcode;    # $doitcode defined above
    print $OutFH "</PRE>\n";
    printtail() unless $Bare;
}

##---------------------------------------------------------------------------
##
sub get_cli_opts() {
    return 0
      unless GetOptions(
        "aliases=s",      # Filename of aliases for actual manpage names
        "bare",           # Leave out HTML, HEAD, BODY tags.
        "belem=s",        # HTML Element for overstruck text (def: "B")
        "botm=i",         # Number of lines for bottom margin (def: 7)
        "cgiurl=s",       # CGI URL for linking to other manpages
        "cgiurlexp=s",    # CGI URL Perl expr for linking to other manpages
        "compress",       # Compress consecutive blank lines
        "externs=s",      # Filename of names to not link to
        "headmap=s",      # Filename of user section head map file
        "index",          # Make an index
        "k",              # Process input from 'man -k' output.
        "leftm=i",        # Character width of left margin (def: 0)
        "nodepage",       # Do not remove pagination lines
        "noheads",        # Do not detect for section heads
        "pgsize=i",       # Number of lines in a page (def: 66)
        "seealso",        # Link to other manpages only in the SEE ALSO section
        "solaris",        # Parse 'man -k' output from a solaris system
        "ssecm=i",        # Character width of subsection margin (def: 3)
        "sun",            # Section heads are not overstruck in input
        "title=s",        # Title of manpage (def: Not defined)
        "toc",            # Generate IDs compatible with HTML::Toc
        "topm=i",         # Number of lines for top margin (def: 7)
        "uelem=s",        # HTML Element for underlined text (def: "I")

        "help"            # Short usage message
      );
    return 0 if defined($opt_help);

    $pgsz = $opt_pgsize || $pgsz;
    if ( defined($opt_nodepage) ) {
        $hdsz = 0;
        $ftsz = 0;
    }
    else {
        $hdsz = $opt_topm if defined($opt_topm);
        $ftsz = $opt_botm if defined($opt_botm);
    }
    $txsz = $pgsz - ( $hdsz + $ftsz );
    $leftmsz = $opt_leftm if defined($opt_leftm);
    $leftm   = ' ' x $leftmsz;
    $ssecmsz = $opt_ssecm if defined($opt_ssecm);
    $ssecm   = ' ' x $ssecmsz;
    $sec_sz  = $leftmsz + $ssecmsz;

    $Bare     = defined($opt_bare);
    $Compress = defined($opt_compress);
    $K        = defined($opt_k);
    $NoDepage = defined($opt_nodepage);
    $NoHeads  = defined($opt_noheads);
    $SeeAlso  = defined($opt_seealso);
    $Solaris  = defined($opt_solaris);
    $Sun      = defined($opt_sun);
    $Toc      = defined($opt_toc);

    $Title = $opt_title || $Title;
    $CgiUrl = $opt_cgiurlexp
      || ( $opt_cgiurl ? qq{return "$opt_cgiurl"} : '' );

    $BTag = $opt_belem || $BTag;
    $UTag = $opt_uelem || $UTag;
    $BTag =~ s/[<>]//g;
    $UTag =~ s/[<>]//g;

    if ( defined($opt_aliases) ) {
        if ( open FP, $opt_aliases ) {
            my @data = <FP>;
            for my $n ( 0 .. $#data ) {
                chomp $data[$n];
                next if ( $data[$n] =~ /^\s*#/ );
                my $key   = $data[$n];
                my $value = $key;
                $key   =~ s/\s.*//;
                $value =~ s/^[^[:blank:]]+\s+//;
                $Aliases{$key} = $value;
            }
        }
        else {
            warn "Unable to read $opt_externs\n";
        }
    }

    if ( defined($opt_externs) ) {
        if ( open FP, $opt_externs ) {
            my @data = <FP>;
            for my $n ( 0 .. $#data ) {
                chomp $data[$n];
                next if ( $data[$n] =~ /^\s*#/ );
                $Externs{ $data[$n] } = 1;
            }
        }
        else {
            warn "Unable to read $opt_externs\n";
        }
    }

    if ( defined($opt_headmap) ) {
        require $opt_headmap or warn "Unable to read $opt_headmap\n";
    }
    1;
}

##---------------------------------------------------------------------------
sub printhead() {
    print $OutFH "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\">\n";
    print $OutFH "<HTML>\n";
    print $OutFH "<HEAD>\n";
    print $OutFH "<meta ", "http-equiv=\"Content-Type\" ",
      "content=\"text/html; charset=us-ascii\">\n";
    print $OutFH "<meta ", "name=\"generator\" ",
      "content=\"Manpage converted by man2html ",
      "- see ", "http://invisible-island.net",
      "/scripts/readme.html#others_scripts\">\n";
    print $OutFH "<TITLE>$Title</TITLE>\n" if $Title;
    print $OutFH "</HEAD>\n";
    print $OutFH "<BODY>\n";
    my $id = "";
    $id = " id=\"toplevel-toc\"" if $Toc;
    print $OutFH "<H1$id class=\"no-header\">$Title</H1>\n" if $Title;
}

##---------------------------------------------------------------------------
sub index_level($) {
    my $value = shift;
    $value =~ s/^.*(\d)>$/$1/;
    return $value;
}

sub printtail() {
    if ( $opt_index and ( $#index >= 0 ) ) {
        print $OutFH "<div class=\"nav\">\n";
        my $level = 2;
        print $OutFH "<ul>\n";
        for my $n ( 0 .. $#index ) {
            my $item = $index[$n];
            my $this = &index_level($item);
            my $next =
              ( $n < $#index ) ? &index_level( $index[ $n + 1 ] ) : $level;
            if ( $level < $next ) {
                $item =~ s/<\/H\d>//;
            }
            if ($Toc) {
                $item =~ s/H\d id=[^>]+>/li>/g;
                $item =~ s/">/-toc">/;
                $item =~ s/name="/href="#/;
                $item =~ s/H\d>/li>/g;
            }
            else {
                $item =~ s/H\d>/li>/g;
                $item =~ s/name="/href="#/;
            }
            printf $OutFH "%s\n", $item;
            if ( $level < $next ) {
                print $OutFH "<ul>\n";
                $level = $next;
            }
            elsif ( $level > $next ) {
                print $OutFH "</ul>\n";
                $level = $next;
                print $OutFH "</li>\n";
            }
        }
        print $OutFH "</ul>\n";
        print $OutFH "</div>\n";
    }
    print $OutFH <<EndOfRef;
</BODY>
</HTML>
EndOfRef
}

##---------------------------------------------------------------------------
sub emphasize($) {
    my ($txt) = shift;
    $txt =~ s/.\010//go;
    $txt = "<$UTag>$txt</$UTag>";
    $txt;
}

##---------------------------------------------------------------------------
sub strongize($) {
    my ($txt) = shift;
    $txt =~ s/.\010//go;
    $txt = "<$BTag>$txt</$BTag>";
    $txt;
}

##---------------------------------------------------------------------------
sub entitize($) {
    my ($txt) = shift;

    ## Check for special characters in overstrike text ##
    $$txt =~ s/_\010\&/strike('_', '&')/geo;
    $$txt =~ s/_\010</strike('_', '<')/geo;
    $$txt =~ s/_\010>/strike('_', '>')/geo;

    $$txt =~ s/(\&\010)+\&/strike('&', '&')/geo;
    $$txt =~ s/(<\010)+</strike('<', '<')/geo;
    $$txt =~ s/(>\010)+>/strike('>', '>')/geo;

    ## Check for special characters in regular text.  Must be careful
    ## to check before/after character in expression because it might be
    ## a special character.
    $$txt =~ s/([^\010]\&[^\010])/htmlize2($1)/geo;
    $$txt =~ s/([^\010]<[^\010])/htmlize2($1)/geo;
    $$txt =~ s/([^\010]>[^\010])/htmlize2($1)/geo;

    # Check for a chunk which looks like the dangling part of a hyphenated
    # and overstruck word, save that into $newc, so we can append it in an
    # HREF at the beginning of the next line.
    my $newc = "";
    my ($x) = $$txt;
    chop $x;
    $x =~ s/^[ ]+([^ ]+[ ]+)+//;
    my ($y) = $x;
    $y =~ s/.\010//g;
    if ( ( $y =~ /^\w+-$/ ) && ( length($y) * 3 <= length($x) ) ) {
        $newc = $y;
        chop $newc;
    }
    $newc;
}

##---------------------------------------------------------------------------
##	escape special characters in a string, in-place
##
sub htmlize($) {
    my ($str) = shift;
    $$str =~ s/&/\&amp;/g;
    $$str =~ s/</\&lt;/g;
    $$str =~ s/>/\&gt;/g;
    $$str;
}

##---------------------------------------------------------------------------
##	htmlize2() is used by entitize.
##
sub htmlize2($) {
    my ($str) = shift;
    $str =~ s/&/\&amp;/g;
    $str =~ s/</\&lt;/g;
    $str =~ s/>/\&gt;/g;
    $str;
}

##---------------------------------------------------------------------------
##	strike converts HTML special characters in overstruck text
##	into entity references.  The entities are overstruck so
##	strongize() and emphasize() will recognize the entity to be
##	wrapped in tags.
##
sub strike($$) {
    my ( $w, $char ) = @_;
    my ($ret);
    if ( $w eq '_' ) {
        if ( $char eq '&' ) {
            $ret = "_$bs\&_${bs}a_${bs}m_${bs}p_${bs};";
        }
        elsif ( $char eq '<' ) {
            $ret = "_$bs\&_${bs}l_${bs}t_${bs};";
        }
        elsif ( $char eq '>' ) {
            $ret = "_$bs\&_${bs}g_${bs}t_${bs};";
        }
        else {
            warn qq|Unrecognized character, "$char", passed to strike()\n|;
        }
    }
    else {
        if ( $char eq '&' ) {
            $ret = "\&$bs\&a${bs}am${bs}mp${bs}p;${bs};";
        }
        elsif ( $char eq '<' ) {
            $ret = "\&$bs\&l${bs}lt${bs}t;${bs};";
        }
        elsif ( $char eq '>' ) {
            $ret = "\&$bs\&g${bs}gt${bs}t;${bs};";
        }
        else {
            warn qq|Unrecognized character, "$char", passed to strike()\n|;
        }
    }
    $ret;
}

##---------------------------------------------------------------------------
##	make_xref() converts a manpage cross-reference into a hyperlink.
##
sub make_xref($) {
    my $str = shift;
    my $fix = $oldc;
    $str =~ s/.\010//go;    # Remove overstriking

    $oldc = "";
    if ( $CgiUrl and ( not defined $Externs{$str} ) ) {
        if ( defined $Aliases{$str} ) {
            warn qq!Mapping alias "$str" to "$Aliases{$str}"\n!;
            $str = $Aliases{$str};
        }
        my ( $title, $section, $subsection ) =
          ( $str =~ /([\+_\.\w-]+)\((\d)(\w?)\)/ );

        $title =~ s/\+/%2B/g;
        my ($href) = ( eval $CgiUrl );
        qq|<B><A HREF="$fix$href">$str</A></B>|;
    }
    else {
        warn qq|Not linked: "$str"\n|;
        qq|<B>$str</B>|;
    }
}

##---------------------------------------------------------------------------
##	man_k() process a keyword search.  The problem we have is there
##	is no standard for keyword search results from man.  Solaris
##	systems have a different enough format to warrant dealing
##	with it as a special case.  For other cases, we try our best.
##	Unfortunately, there are some lines of results that may be
##	skipped.
##
sub man_k() {
    my (
        $line, $refs,    $section, $subsection, $desc, $i,
        %Sec1, %Sec1sub, %Sec2,    %Sec2sub,    %Sec3, %Sec3sub,
        %Sec4, %Sec4sub, %Sec5,    %Sec5sub,    %Sec6, %Sec6sub,
        %Sec7, %Sec7sub, %Sec8,    %Sec8sub,    %Sec9, %Sec9sub,
        %SecN, %SecNsub, %SecNsec
    );

    printhead() unless $Bare;
    print $OutFH "<!-- Man keyword results converted by ",
      "man2html $VERSION -->\n";

    while ( $line = <$InFH> ) {
        next if $line !~ /\(\d\w?\)\s+-\s/;    # check if line can be handled
        ( $refs, $section, $subsection, $desc ) =
          $line =~ /^\s*(.*)\((\d)(\w?)\)\s*-\s*(.*)$/;

        if ($Solaris) {
            $refs =~ s/^\s*([\+_\.\w-]+)\s+([\+_\.\w-]+)\s*$/$1/;

            #  <topic> <manpage>
        }
        else {
            $refs =~ s/\s(and|or)\s/,/gi;      # Convert and/or to commas
            $refs =~ s/^[^:\s]:\s*//;          # Remove prefixed whatis path
        }
        $refs =~ s/\s//g;                      # Remove all whitespace
        $refs =~ s/,/, /g;                     # Put space after comma
        htmlize( \$desc );                     # Check for special chars in desc
        $desc =~ s/^(.)/\U$1/;                 # Uppercase first letter in desc

        if ( $section eq '1' ) {
            $Sec1{$refs}    = $desc;
            $Sec1sub{$refs} = $subsection;
        }
        elsif ( $section eq '2' ) {
            $Sec2{$refs}    = $desc;
            $Sec2sub{$refs} = $subsection;
        }
        elsif ( $section eq '3' ) {
            $Sec3{$refs}    = $desc;
            $Sec3sub{$refs} = $subsection;
        }
        elsif ( $section eq '4' ) {
            $Sec4{$refs}    = $desc;
            $Sec4sub{$refs} = $subsection;
        }
        elsif ( $section eq '5' ) {
            $Sec5{$refs}    = $desc;
            $Sec5sub{$refs} = $subsection;
        }
        elsif ( $section eq '6' ) {
            $Sec6{$refs}    = $desc;
            $Sec6sub{$refs} = $subsection;
        }
        elsif ( $section eq '7' ) {
            $Sec7{$refs}    = $desc;
            $Sec7sub{$refs} = $subsection;
        }
        elsif ( $section eq '8' ) {
            $Sec8{$refs}    = $desc;
            $Sec8sub{$refs} = $subsection;
        }
        elsif ( $section eq '9' ) {
            $Sec9{$refs}    = $desc;
            $Sec9sub{$refs} = $subsection;
        }
        else {    # Catch all
            $SecN{$refs}    = $desc;
            $SecNsec{$refs} = $section;
            $SecNsub{$refs} = $subsection;
        }
    }
    print_mank_sec( \%Sec1, 1,   \%Sec1sub );
    print_mank_sec( \%Sec2, 2,   \%Sec2sub );
    print_mank_sec( \%Sec3, 3,   \%Sec3sub );
    print_mank_sec( \%Sec4, 4,   \%Sec4sub );
    print_mank_sec( \%Sec5, 5,   \%Sec5sub );
    print_mank_sec( \%Sec6, 6,   \%Sec6sub );
    print_mank_sec( \%Sec7, 7,   \%Sec7sub );
    print_mank_sec( \%Sec8, 8,   \%Sec8sub );
    print_mank_sec( \%Sec9, 9,   \%Sec9sub );
    print_mank_sec( \%SecN, 'N', \%SecNsub, \%SecNsec );

    printtail() unless $Bare;
}
##---------------------------------------------------------------------------
##	print_mank_sec() prints out manpage cross-refs of a specific section.
##
sub print_mank_sec($$$$) {
    my ( $sec, $sect, $secsub, $secsec ) = @_;
    my ( @array, @refs, $href, $item, $title, $subsection, $i, $section,
        $xref );
    $section = $sect;

    @array = sort keys %$sec;
    if ( $#array >= 0 ) {
        print $OutFH "<H2>Section $section</H2>\n", "<DL COMPACT>\n";
        foreach $item (@array) {
            @refs = split( /,/, $item );
            $section = $secsec->{$item} if $sect eq 'N';
            $subsection = $secsub->{$item};
            if ($CgiUrl) {
                ( $title = $refs[0] ) =~ s/\(\)//g;   # watch out for extra ()'s
                $xref = eval $CgiUrl;
            }
            print $OutFH "<DT>\n";
            $i = 0;
            foreach (@refs) {
                if ($CgiUrl) {
                    print $OutFH qq|<B><A HREF="$xref">$_</A></B>|;
                }
                else {
                    print $OutFH $_;
                }
                print $OutFH ", " if $i < $#refs;
                $i++;
            }
            print $OutFH " ($section$subsection)\n",
              "</DT><DD>\n",
              $sec->{$item}, "</DD>\n";
        }
        print $OutFH "</DL>\n";
    }
}

##---------------------------------------------------------------------------
##
sub usage() {
    print $OutFH <<EndOfUsage;
Usage: $PROG [ options ] < infile > outfile
Options:
  -aliases <file>  : Filename containing mapping of aliases to actual manpages
  -bare            : Do not put in HTML, HEAD, BODY tags
  -belem <elem>    : HTML Element for overstruck text (def: "B")
  -botm <#>        : Number of lines for bottom margin (def: 7)
  -cgiurl <url>    : URL for linking to other manpages
  -cgiurlexp <url> : Perl expression URL for linking to other manpages
  -compress        : Compress consecutive blank lines
  -externs <file>  : Filename containing names to not link to
  -headmap <file>  : Filename of user section head map file
  -help            : This message
  -index           : Make an index of headers at the end
  -k               : Process a keyword search result
  -leftm <#>       : Character width of left margin (def: 0)
  -nodepage        : Do not remove pagination lines
  -noheads         : Turn off section head detection
  -pgsize <#>      : Number of lines in a page (def: 66)
  -seealso         : Link to other manpages only in the SEE ALSO section
  -solaris         : Process keyword search result in Solaris format
  -ssecm <#>       : Character width of subsection margin (def: 0)
  -sun             : Section heads are not overstruck in input
  -title <string>  : Title of manpage (def: Not defined)
  -toc             : Generate IDs compatible with HTML::Toc
  -topm <#>        : Number of lines for top margin (def: 7)
  -uelem <elem>    : HTML Element for underlined text (def: "I")

Description:
  $PROG takes formatted manpages from STDIN and converts it to HTML sent
  to STDOUT.  The -topm and -botm arguments are the number of lines to the
  main body text and NOT to the running headers/footers.

Version:
  $VERSION
  Copyright 2001-2014,2015 Thomas E. Dickey
  Copyright (C) 1995-1997  Earl Hood, ehood\@medusa.acs.uci.edu
  $PROG comes with ABSOLUTELY NO WARRANTY and $PROG may be copied only
  under the terms of the GNU General Public License, which may be found in
  the $PROG distribution.

EndOfUsage
    exit 0;
}

#############################################################################
##	Main Block
#############################################################################
{
    if ( get_cli_opts() ) {
        if ($K) {
            &man_k;
        }
        else {
            &do_it;
        }
    }
    else {
        &usage;
    }
}
