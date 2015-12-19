#! /usr/bin/env bash
#Source: http://sourceforge.net/projects/gettumblrpics/
#License: Unknown
#Description: Dowload pictures from http://tumblr.com blogs
#Usage: gettumblrpics.sh name_of_tumblr number_of_pages_to_get

site=$1
pages=$2

# create the folder named after the site, and then move into it
mkdir $site
cd $site

# grab the first page of images, as we are always going to want that.
curl --silent "${site}.tumblr.com" | grep -o '<img src="[^"]*' | grep -o '[^"]*$' > image_list.txt

# if we have asked for more than one page, loop through and get the rest
if [ "$pages" != "" ]; then
    for ((i=2; i<=$pages; i++)) do
        curl --silent "${site}.tumblr.com/page/${i}" | grep -o '<img src="[^"]*' | grep -o '[^"]*$' >> image_list.txt
    done;
fi

# lets get a unique list of the files in the image list
sort -u "image_list.txt" > "image_list2.txt"

# now that we have built up our list, we should download the images
wget --quiet --input-file="image_list2.txt"

# remove our temp files
rm -f "image_list.txt"
rm -f "image_list2.txt"