#!/usr/bin/env bash

##########################################################################
# Title      :	icat - "intelligent" cat
# Author     :	Heiner Steven <heiner.steven@odn.de>
# Date	     :	1994-05-18
# Requires   :	gzip, zcat
# Category   :	File Utilities
# SCCS-Id.   :	@(#) icat	1.3 08/01/31
##########################################################################

PN=`basename "$0"`			# program name
VER='1.3'

Extensions=".Z .z .gz .cpz .tgz"		# known file extensions
usage () {
    echo >&2 "$PN - cat file, uncompress if necessary, $VER (stv '95)
usage: $PN -l
       $PN [file ...]

The first case lists all known extensions, the other case tries
to print the given file, uncompressing it if necessary."
    exit 1
}

msg () {
    for line
    do echo "$PN: $line" >&2
    done
}

fatal () { msg "$@"; exit 1; }

while [ $# -gt 0 ]
do
    case "$1" in
	-l)				# List known suffixes
	    echo $Extensions
	    exit 0;;
	--) shift; break;;		# Simulate getopt
        -h) usage;;
	*)  break;;
    esac
done

if [ $# -lt 1 ]
then					# read from stdin (uncompressed)
    cat
else
    for file
    do
	if [ -r "$file" ]		# file does exist
	then
	    # Try to determine decompressor based on the extension
	    case "$file" in
		*.Z)    zcat "$file";;
		*.z)    gzip -d -c "$file";;
		*.gz|*.tgz)   gzip -d -c "$file";;
		*.bz2)	bzip2 -d -c "$file";;
		*.cpz)	zcat < "$file";;
		*)	cat "$file";;
	    esac
	else
	    # File does not exist: try to determine compressed version
	    if [ -r "$file".bz2 ]
	    then
		bzip2 -d -c "$file"
	    elif [ -r "$file".gz ]
	    then
		gzip -d -c "$file"
	    elif [ -r "$file".tgz ]
	    then
		gzip -d -c "$file"
	    elif [ -r "$file".Z ]
	    then
		zcat "$file"
	    elif [ -r "$file".z ]
	    then
		gzip -d -c "$file"
	    elif [ -r "$file".cpz ]
	    then
		zcat < "$file"
	    else
		fatal "could not find file: $file"
	    fi
	    Err=$?
	fi
    done
fi
exit ${Err:-0}

