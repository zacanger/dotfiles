##########################################################################
# Title      :	whodo - who is doing what
# Author     :	Heiner Steven <heiner.steven@odn.de>
# Date       :	1995-04-26
# Requires   :	
# Category   :	System Utilities
# SCCS-Id.   :	@(#) whodo	1.2 03/12/19
##########################################################################
# Description
#	Show who is logged on and what he is doing.
#	This program works like the System V "whodo" command.
##########################################################################

PN=`basename "$0"`			# program name
VER='1.2'

usage () {
    echo >&2 "$PN - who is doing what, $VER (stv '95)
usage: $PN [-l] [-h] [user]
    -h: suppress the heading
    -l:	long form of output"
    exit 1
}

msg () {
    for i
    do echo "$PN: $i" >&2
    done
}

fatal () { msg "$@"; exit 1; }

LongOutput=no
Header=yes
while [ $# -gt 0 ]
do
    case "$1" in
	-l)	LongOutput=yes;;
	-h)	Header=no;;
	--)	shift; break;;
	-*)	usage;;
	*)	break;;			# First file name
    esac
    shift
done

[ $# -gt 0 ] && User="$1"

if [ "$LongOutput" = no ]
then
    [ $Header = yes ] && {
	date
	uname -n
    }

    # Sample output of who:
    #	heiner   console Apr 26 08:18
    who |
	while read Name Tty Mon Day Time Host Rest
	do
	    [ -n "$User" -a "$User" != "$Name" ] && continue
	    echo "
$Tty	$Name	$Time"
	    case "$Tty" in
		*tty*)	T=`echo "$Tty" | sed -e 's:.*tty\(..\).*:\1:'`;;
		*)	T=`echo "$Tty" | sed -e 's:/dev/\(..\).*:\1:'`;;
	    esac

	    # Sample output of ps -c:
	    #	PID TT STAT  TIME COMMAND
	    #	327 p2 IW    0:19 ksh
	    ps -ct"$T" | tail +2 |
		while read pid tty stat time command
		do
		    echo "    $Tty	$pid	$time	$command"
		done
	done
else
    # Long form: use "w" output format
    if [ $Header = yes ]
    then FirstLine=1
    else FirstLine=3
    fi
    if [ -z "$User" ]
    then
	w
    else
	w | grep "$User"
    fi | tail +$FirstLine
fi