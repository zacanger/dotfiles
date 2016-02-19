#!/usr/bin/env bash

# ./this-script.sh foo.css (makes a foo.min.css)
# ./this-script.sh foo.js  (makes a foo.min.js )

f=$1
name=${f%.*}
ext=${f##*.}

case "$ext" in
 "js") website="javascript-minifier" ;;
 "css") website="cssminifier" ;;
 *) echo "Invalid extension"; exit ;;
esac

wget --post-data="input=`cat $name.$ext`" --output-document=$name.min.$ext https://$website.com/raw

