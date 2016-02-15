#!/bin/sh

# This is semi-inteligent script which tries to make diff between two
# directories which can have slightly different files (e.g. with or
# without .in at end of filename) or different directory structure. It won't
# work well if you have files which have same name in more than one place in
# source directory!

if [ -z "$1" -o -z "$2" ] ; then
	echo "Usage: $0 [original source dir] [changed source dir]"
	exit 1;
else
	s=$1
	d=$2
fi

find $s -type f | while read sfile ; do
	sfilename=`basename $sfile | sed 's/\.in$//'`
	dfile=`find $d -iname "$sfilename"`
	if [ -z "$dfile" ] ; then
		echo "Only in $s: $sfilename"
	else
		echo "diff -uw $sfile $dfile"
		diff -uw $sfile $dfile
	fi
done