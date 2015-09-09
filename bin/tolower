##########################################################################
# Shellscript:	tolower - rename files to all lower case
# Version    :	1.2
# Author     :	Heiner Steven (heiner.steven@odn.de)
# Date       :	1995-03-02
# Category   :	File Utilities
# SCCS-Id.   :	@(#) tolower	1.2 04/02/18
##########################################################################
# Description
#
##########################################################################

PN=`basename "$0"`			# program name
VER='1.2'

Usage () {
    echo >&2 "$PN - rename files to all lower case, $VER (stv '95)
usage: $PN [-v] file [...]
    -v:  print number of renamed files"
    exit 1
}

Msg () {
    for i
    do echo "$PN: $i" >&2
    done
}

Fatal () { Msg "$@"; exit 1; }

while [ $# -gt 0 ]
do
    case "$1" in
	--)	shift; break;;
	-v)	verbose=yes;;		# yes/no
	-h)	Usage;;
	-*)	Usage;;
	*)	break;;			# First file name
    esac
    shift
done

[ $# -lt 1 ] && Usage

Errs=0
n=0
for i
do
    Lower=`echo "$i" | tr '[A-Z]' '[a-z]'`

    if [ "$i" = "$Lower" ]
    then
	continue			# name is already in lower case
    elif [ -r "$Lower" -o -w "$Lower" -o -x "$Lower" ]
    then
	Msg "could not rename $i: $Lower exists already"
	continue
    fi

    if mv "$i" "$Lower"
    then
	n=`expr $n + 1`
    else
	Errs=`expr $Errs + 1`
	Msg "could not rename $i to $Lower"
    fi
done
[ "$verbose" = yes ] && Msg "$n files renamed"
exit $Errs