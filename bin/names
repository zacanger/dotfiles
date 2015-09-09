#!/bin/bash
# Convert filenames to lowercase
# and replace characters recursively
#####################################

if [ -z "$1" ];then echo Give target directory; exit 0;fi

find "$1" -depth -name '*' | while read file ; do
        directory=$(dirname "$file")
        oldfilename=$(basename "$file")
        newfilename=$(echo "$oldfilename" | tr 'A-Z' 'a-z' | tr ' ' '_' | sed 's/_-_/-/g')
        if [ "$oldfilename" != "$newfilename" ]; then
                mv -i "$directory/$oldfilename" "$directory/$newfilename"
                echo ""$directory/$oldfilename" ---> "$directory/$newfilename""
                #echo "$directory"
                #echo "$oldfilename"
                #echo "$newfilename"
                #echo
                #tr 'A-Z' 'a-z' 
        fi
        done
exit 0