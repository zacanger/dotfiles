#!/bin/sh
#This script was created 17/5/2010 by Paul Tero (www.tero.co.uk/scripts/minify.php) to remove comments
#and extra spaces from Javascript and CSS files.

#There must be at least 1 argument, which is the CSS and JS files to compress
if test $# -lt 1; then echo Usage $0 CSS-or-JS-file; exit 1; fi

#If the file name is something like myfile-raw.js, then it will output automatically to myfile.js, removing the -raw.
outfile=`echo $1 | sed -e "s|-raw.\(.*\)$|.\1|"`
if test "$1" = "$outfile"; then outfile=/dev/stdout; 
else echo Minimising $1 and outputting to $outfile;
fi;

#This command removes comments from CSS and Javascript files using sed. First it replaces /**/ and /*\*/ with 
#/~~/ and /~\~/ as these comments are used as CSS hacks and should stay in the file. Then it removes /*...*/ style
#comments on single lines (from Javascript and CSS files). Then it removes // style comments from Javascript files
#(done in this order so that comments like /*...//...*/ get removed properly). Then it replaces all newlines with
#spaces and removes /*...*/ style comments again (this time over multiple lines). Then it puts the /**/ and /*\*/
#CSS hacks back in. Then it replaces multiple spaces with single spaces. Then it removes spaces before [{;:,] and
#then spaces after [{:;,].
cat $1 | sed -e "s|/\*\(\\\\\)\?\*/|/~\1~/|g" -e "s|/\*[^*]*\*\+\([^/][^*]*\*\+\)*/||g" -e "s|\([^:/]\)//.*$|\1|" -e "s|^//.*$||" | tr '\n' ' ' | sed -e "s|/\*[^*]*\*\+\([^/][^*]*\*\+\)*/||g" -e "s|/\~\(\\\\\)\?\~/|/*\1*/|g" -e "s|\s\+| |g" -e "s| \([{;:,]\)|\1|g" -e "s|\([{;:,]\) |\1|g" > $outfile
echo