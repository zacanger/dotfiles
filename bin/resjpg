#!/bin/bash
# FILE : bbresize
# Function: Resizes all .jpg images in a directory.
# Copyright (C) 2006-2009 Dave Crouse <crouse@usalug.net>
# ------------------------------------------------------------------------ #
if [[ -z $( type -p convert ) ]]; then echo -e "ImageMagick -- NOT INSTALLED !";exit ;fi

if [[ $1 = "--help" || $1 = "-h" || $1 = "help" ]]; then
        echo "          Function: Resizes all .jpg images in a directory.";
        echo "          Usage: $0 width height";
        echo "          Requires: Imagemagick";
        echo "          EXAMPLE: $0 400 400";
        echo "          Note: width and height variables MUST be numeric ! ";
        echo "          In the example 400 400 creates images with a maximum width of 400 and maximum height of 400.";
        echo "          ";
        echo "          Comments/Suggestions/Bugfixes to <crouse@usalug.net>";
        echo "          USA Linux Users Group - http://usalug.org";
        echo "          ";
exit 0
fi

if [[ -z "$2" || $1 = *[^0-9]* || $2 = *[^0-9]* ]] ; then
        echo " ";
        echo "          ######### COMMAND FAILED ########## ";
        echo "          USAGE: $0 width height";
        echo "          EXAMPLE: $0 400 400";
        echo "          Note: width and height variables MUST be numeric ! ";
        echo "          In the example 400 400 creates images with a maximum width of 400 and maximum height of 400.";
        echo "          ######### COMMAND FAILED ########## ";echo " ";
else

export IFS=$'\n';
for i in $(find . -maxdepth 1 -type f -iname "*.jpg");
do
echo "Resizing ${i:2} to $1 x $2";convert ${i:2} -resize $1\x$2 new_${i:2}; mv new_${i:2} ${i:2} ;
done
fi
exit 0