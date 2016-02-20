#!/usr/bin/env bash

# creates index of all .jpg images in `cwd`.
# does not include .jpeg or .JPG or .JPEG files.
# so, name your shit reasonably.
# asshole.

if [[ $1 = "--help" || $1 = "-h" || $1 = "help" ]]; then
        echo "          Function: Creates a visual index of all the .jpg images in the directory.";
        echo "          Usage: $0";
        echo "          Requires: Imagemagick";
        echo "          ";
        echo "          Comments/Suggestions/Bugfixes to <crouse@usalug.net>";
        echo "          USA Linux Users Group - http://usalug.org";
        echo "          ";
exit 0
fi

if [[ -z $( type -p convert ) ]]; then echo -e "ImageMagick -- NOT INSTALLED !";exit ;fi

export IFS=$'\n';
convert vid:*.jpg INDEX.jpg;
exit 0
