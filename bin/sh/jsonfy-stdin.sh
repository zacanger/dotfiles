#!/bin/sh
# Author: Andreas Louv <andreas@louv.dk>
# This program reads each line from STDIN and output an
# JSON array containing those lines:
# $'a\nb\nc\n12.34' -> ["a", "b", "c", 12.34]
empty='""'
case $1 in
	--null|-n) empty=null;;
esac
sed 's/"/\\"/;s/^$/'"$empty"',/;te;s/^[0-9]*\.*[0-9]*$/&,/;te;s/.*/"&",/;:e;1s/^/[/;$s/,$/]/' | tr -d '\n'
