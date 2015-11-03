#!/bin/bash

# A script to only keep images of a certain size in a directory
# by Philip Guo
# http://alum.mit.edu/www/pgbovine/
# Copyright 2005 Philip J. Guo
#
# Created: 2005-08-26
# Last modified: 2005-08-27

# Requires: ImageMagick

# Usage: ./keep-images-larger-than.sh <min-width> <min-height>

# Recurses into all sub-directories and moves all images which have
# width or height less than min-width or min-height, respectively,
# into a small-images-trash sub-directory that it creates.  Then it
# moves all sub-directories that don't contain any .jpg images into
# small-images-trash/no-jpg-dirs

# This script is useful to run after harvesting a bunch of images
# using image-harvester.py in order to filter out advertisements,
# banners, and thumbnail images.

#     This program is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     (at your option) any later version.

#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.


minwidth=$1
minheight=$2

echo Min. width: $minwidth, Min. height: $minheight

mkdir small-images-trash
mkdir small-images-trash/no-jpgs-dirs

# Only works on .jpg for now (case sensitive):
for img in `find . -name '*.jpg'`
do
    # This ImageMagick command returns the width & height
    # of an image separated by spaces:
    dims=(`identify -format "%w %h" $img`)
    width=${dims[0]}
    height=${dims[1]}

    echo $img

    # Remember to do a *numeric* less-than comparison (-lt) and not a
    # string comparison (<) in order to get the desired results:
    if [[ ($width -lt $minwidth) || ($height -lt $minheight) ]]
    then
	mv $img small-images-trash/
	echo "  TOO SMALL!"
    fi
done


# Move all sub-directories which don't contain any JPG
# images into ./small-images-trash/no-jpgs-dirs
for dir in `find . -type d`
do
    # Ignore these directories:
    if [[ !($dir = "./small-images-trash") &&
	  !($dir = "./small-images-trash/no-jpgs-dirs") ]]
    then
	jpgList=`find $dir -name '*.jpg'`
	if [[ -z $jpgList ]]
	then
	    echo No JPGs in $dir
	    mv $dir small-images-trash/no-jpgs-dirs
	fi
    fi
done
