:
##########################################################################
# Title      :	finddup - find duplicate files
# Author     :	Heiner Steven <heiner.steven@odn.de>
# Date       :	2002-09-16
# Requires   :	sum
# Category   :	File Utilities
# SCCS-Id.   :	@(#) finddup	1.3 04/12/01
##########################################################################
# Description
#	Prints a list of duplicate files. Files are assumed to
#	be identical if they have the same checksum as calculated
#	by the $SUM program below (preferred: "md5sum").
#
# Note
#    o	Cannot handle files with embedded LF (ASCII 10) characters
#    o	If a large number of files has the same checksum, they
#	probably have a file size of 0 bytes.
#    o	For improved speed the program could sort files by file
#	size, and only compare files with equal size
##########################################################################

PN=`basename "$0"`			# Program name
VER='1.3'

# Set the following variables to disable the search for the best program:
#SUM=
#NAWK=

findargs="-type f"

###############################################################################
# searchprog - search program using search PATH
# usage: searchprog program
###############################################################################

searchprog () {
    _search=$1; shift

    for _dir in `echo "$PATH" | sed "s/^:/.:/;s/:\$/:./;s/:/ /g"`
    do
        [ -x "$_dir/$_search" ] || continue
        echo "$_dir/$_search"
        return 0
    done

    return 1
}

Usage () {
    echo >&2 "$PN - find duplicate files, $VER
usage: $PN [-lv] path [path ...] [findargs]
    -l:  long output format
    -v:  print progress messages

The path specifications can be directories or files. \"findargs\" are
parameters to the find(1) command, the default is \"$findargs\".

The short output format lists the number of duplicate files,
and a list of files separated by TAB all in one line.

The long output format lists the number of duplicates and
the checksum in one line, followed by a colon. After that the file
names follow, each on a separate line."
    exit 1
}

Msg () {
    for MsgLine
    do echo "$PN: $MsgLine" >&2
    done
}

Fatal () { Msg "$@"; exit 1; }

set -- `getopt :hlv "$@" || exit 1` || Usage
[ $# -lt 1 ] && Usage			# "getopt" detected an error

LongOutput=false
Verbose=false
while [ $# -gt 0 ]
do
    case "$1" in
    	-l)	LongOutput=true;;
	-v)	Verbose=true;;
	--)	shift; break;;
	-h)	Usage;;
	-*)	Usage;;
	*)	break;;			# First file name
    esac
    shift
done

[ $# -lt 1 ] && Usage

: ${NAWK:=`searchprog mawk || searchprog gawk || searchprog nawk || echo awk`}

# Find a program to calculate the checksum. "md5sum" generates better
# checksums than BSD "sum", which still creates better checksums than
# System V "sum".

: ${SUM:=`searchprog md5sum || searchprog cksum || searchprog sum`}

# Configure the input column numbers AWK should use as checksum. Be
# careful when changing the following lines, because quoting is
# important.

case "$SUM" in
    *md5sum)	fieldlist='$1';;
    *cksum)	fieldlist='$1 " " $2';;		# Solaris
    *sum)	fieldlist='$1 " " $2';;
    *)		Fatal "cannot find \"md5sum\" or \"sum\"";;
esac

[ $Verbose = true ] && Msg "using programs SUM=$SUM; NAWK=$NAWK"

find "$@" $findargs -print -exec "$SUM" {} \; |
	"$NAWK" '
	    BEGIN {
		longoutput = ("'"$LongOutput"'" == "true")
		verbose = ("'"$Verbose"'" == "true")
		if ( longoutput ) {
		    filesep = "\n"
		} else {
		    filesep = "\t"
		}
	    }
	    !file {				# first line is file
		file = $0
		#print "DEBUG:", file | "cat >&2"
		next
	    }
	    {				# second line is checksum
		idx = '"$fieldlist"'
		#print "DEBUG:", idx
		if (files[idx] != "" ) files[idx] = files[idx] filesep

		files[idx] = files[idx] file
		if ( ++count[idx] > 1 ) ++dups
		file = ""
		++filecnt

		if ( verbose && !(filecnt % 100) ) {
		    print filecnt+0, "files,", dups+0, "duplicates" | "cat >&2"
		}
	    }
	    END {
	    	dups = 0
		for (idx in files) {
		    if ( count[idx] > 1 ) {
			++dups
			if ( longoutput ) {
			    print count[idx], "x", idx ":"
			    n = split (files[idx], f, filesep)
			    for ( i=1; i<=n; ++i ) print f[i]
			} else {
			    print count[idx] filesep files[idx]
			}
		    }

		}
		exit (dups > 0)	# non-zero if duplicate found
	    }
	'

# exits with "0" if no duplicates were found, "1" otherwise