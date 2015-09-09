#!/bin/bash
# FILE : bbborder
# Function: Puts a border on all .jpg images in the directory.
# Copyright (C) 2006-2009 Dave Crouse <crouse@usalug.net>
# ------------------------------------------------------------------------ #
if [[ $1 = "--help" || $1 = "-h" || $1 = "help" ]]; then
        echo "          Function: Puts a border on all .jpg images in the directory.";
        echo "          Usage: $0 bordercolor bordersize";
        echo "          Requires: Imagemagick";
        echo "          EXAMPLE: $0 black 6";
        echo "          ";
        echo "          Comments/Suggestions/Bugfixes to <crouse@usalug.net>";
        echo "          USA Linux Users Group - http://usalug.org";
        echo "          ";
exit 0
fi

if [[ -z $( type -p convert ) ]]; then echo -e "ImageMagick -- NOT INSTALLED !";exit ;fi

if [[ -z "$1" || -z "$2" ]]; then
        echo " ";
        echo "          ######### COMMAND FAILED ########## ";
        echo "          USAGE: $0 bordercolor bordersize";
        echo "          EXAMPLE: $0 black 6";
        echo "          ######### COMMAND FAILED ########## ";echo " ";
        exit
else

export IFS=$'\n';
for i in $(find . -maxdepth 1 -type f -iname "*.jpg");
do
convert -bordercolor $1 -border $2x$2 ${i:2} _${i:2}
mv _${i:2} ${i:2}
echo "Created border on ${i:2}" ;
done
fi
exit 0