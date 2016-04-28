#!/usr/bin/env bash

# mkurl - convert text containing URLs to HTML

nawk '
    BEGIN { inlist = 0; URLfound = 0 }

    $0 ~ /[a-z][a-z]*:\/\// {
	if ( !inlist ) {
	    inlist = 1
	    print "<UL>"
	}

	for ( i=1; i<=NF; i++ ) {
	    if ( $i ~ /^[a-z][a-z]*:\/\// ) {
		printf ("  <LI>	<A HREF=\"%s\">", $i)
		if ( i < NF ) {
		    for ( j=i+1; j<=NF; j++ ) printf (" %s", $j);
		} else {
		    # No description: repeat URL.
		    printf (" %s", $i)
		}
		print "</A>"
		break
	    } else {
		printf ("%s", $i);
	    }
	    if ( i == NF ) print ""; else printf (" ");
	}
	next
    }

    $0 != "" && $0 !~ /^[ 	]*$/ {
	if ( inlist ) {
	    print "</UL>"
	    inlist = 0
	}
	print
    }

    END {
	if ( inlist ) print "</UL>"
    }
' "$@"

