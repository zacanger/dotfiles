#!/bin/sh

# Run pngcrush recursively on an entire directory

command -v pngcrush >/dev/null 2>&1 || { echo "PNGCRUSH not found. Please install it and try again"; exit 1; }

if test -z $1; then { echo "No directory specified."; echo "Usage: pngcrushdir [DIRNAME]"; exit 1; }; fi

for png in `find $1 -name "*.png"`;
do
	echo "crushing $png"	
	pngcrush -brute "$png" temp.png
	mv -f temp.png $png
done;
