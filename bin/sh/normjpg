#!/bin/bash
# FILE : bbnormalize
# Function: Normalizes all .jpg images in the directory.
# Copyright (C) 2006-2009 Dave Crouse <crouse@usalug.net>
# ------------------------------------------------------------------------ #
if [[ $1 = "--help" || $1 = "-h" || $1 = "help" ]]; then
        echo "          Function: Normalizes all .jpg images in the directory.";
        echo "          Usage: $0 ";
        echo "          Requires: Imagemagick";
        echo "          ";
        echo "          Comments/Suggestions/Bugfixes to <crouse@usalug.net>";
        echo "          USA Linux Users Group - http://usalug.org";
        echo "          ";
exit 0
fi

if [[ -z $( type -p convert ) ]]; then echo -e "ImageMagick -- NOT INSTALLED !";exit ;fi

export IFS=$'\n';
for i in $(find . -maxdepth 1 -type f -iname "*.jpg");
do
convert -normalize ${i:2} _${i:2};
mv _${i:2} ${i:2}
echo "Normalized image ${i:2}" ;
done
exit 0