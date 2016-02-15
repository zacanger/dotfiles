:
##########################################################################
# Title      :	scriptdeps - print depencency list for shell scripts
# Author     :	Heiner Steven <heiner.steven@odn.de>
# Date       :	2002-04-09
# Requires   :	-
# Category   :	System Administration
# SCCS-Id.   :	@(#) scriptdeps	1.3 03/05/23
##########################################################################
# Description
#	Prints a list of programs and scripts needed to run a certain
#	shell script. Evaluates the "Requires" header field. Note that
#	the header field only contains non-standard programs.
##########################################################################

PN=`basename "$0"`			# Program name
VER='1.3'

Usage () {
    echo >&2 "$PN - print dependency list for shell scripts, $VER
usage: $PN [-dhpv] script [...]
    -d:  dump dependency list (target dependency [depencendy ...])
    -h:  print this usage message
    -p:  print full path name of required programs (instead of base name)
    -v:  immediately print dependencies from the \"Requires\" header"
    exit 1
}

Msg () {
    for MsgLine
    do echo "$PN: $MsgLine" >&2
    done
}

Fatal () { Msg "$@"; exit 1; }

# Search a command in all directories in $PATH, and return the full path
# name to the program.

search () { # progname
    if [ -z "$mypath" ]
    then	# cache modified PATH
    	mypath=`echo "$PATH" | sed 's/^:/.:/;s/:$/:./;s/::/:.:/g;s/:/ /g'`
    fi

    case "$1" in
    	/*)	echo "$1" ;;		# Absolute path name
	*)
	    for dir in $mypath
	    do
		[ -x "$dir/$1" ] || continue
		echo "$dir/$1"; break
	    done
	;;
    esac
}

printonce () { # [filename ...]
    awk 'L[$0]++ == 0' "$@"		# print each line exactly once
}

showdeps () {
    egrep '#[ 	]*Requires[ 	]*:' "$@" |
    	cut -d: -f2- |
	sed 's/^[ 	]*//g;s/[ 	]*$//g;q' |	# trim line
	tr -d '[,;]' |			# remove field separators
	printonce |
	grep .
}

set -- `getopt :dhpv "$@" || exit 1` || Usage
[ $# -lt 1 ] && Usage			# "getopt" detected an error

Dump=false
Fullpath=false
Verbose=false
while [ $# -gt 0 ]
do
    case "$1" in
	-d)	Dump=true;;
	-v)	Verbose=true;;
	-p)	Fullpath=true;;
	--)	shift; break;;
	-h)	Usage;;
	-*)	Usage;;
	*)	break;;			# First file name
    esac
    shift
done

# Determine program dependencies. Get the names of the programs/scripts
# the commands in $@ depend on, and recursively get their dependencies
# as well.
#
# Note that we may run into the limits of the shell, because we use
#    o	the argument list $@ as a "stack" of the program names to check
#    o	the environment variable "depcache" as a "cache" of programs with
#	their dependencies (to speed up processing and prevent
#	infinite loops)
#
# If this becomes an issue, temporary files should be used for this
# purpose.

depcache=
notfound=				# programs not found
while [ $# -gt 0 ]
do
    prog=`search "$1"`
    if [ -z "$prog" ] && [ X"$1" != X- ]
    then
	# Program not found. At the end we will print a list of all programs
	# requiring this file

	notfound="$notfound
$1"

    elif echo "$depcache" |
    	awk -F'	' '$1 == "'"$prog"'" {e=1; exit (e)} END{exit (e)}'
    then
	# "Cache" depencencies to speed up processing, and to prevend
	# infinite loops: "a depends on b", "b depends on a"

	if $Fullpath
	then echo "$prog"
	else echo "$1"
	fi

	deps=`showdeps "$prog" || exit 1`
	if [ $? -eq 0 ] && [ -n "$deps" ]
	then
	    # Cache the dependencies, and append them to the list of programs
	    # to process.

	    $Verbose && echo >&2 "$1 depends on $deps"
	    depcache="$depcache
$prog	$deps"
	    set -- "$@" $deps
	fi
    else
    	: #echo >&2 "DEBUG: already processed: $prog"
    fi
    shift
done

# Processing finished. Now (once) print a list of all unresolved
# dependencies, and the programs that required them:

if [ -n "$notfound" ]
then
    for file in `echo "$notfound" | printonce`
    do
	Msg "ERROR: program $file not found; required by"
	echo "$depcache" |
	    awk "/([ 	]$file )|([ 	]$file\$)/ { print \"\t\" \$1 }" >&2
    done
fi

if $Dump
then
    Msg "dependency table:"
    echo >&2 "$depcache"
fi

exit 0