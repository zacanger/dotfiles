#!/usr/bin/env bash

# convert filenames to lowercase and replace characters recursively

if [ -z "$1" ]; then
  echo target directory please
  exit 0
fi

find "$1" -depth -name '*' | while read file ; do
  directory=$(dirname "$file")
  oldfilename=$(basename "$file")
  # tr -d '[{}(),\!]' | tr -d "\'"
  newfilename=$(echo "$oldfilename" | tr 'A-Z' 'a-z' | tr ',' '_' | tr '[' '-' | tr ']' '-' | tr "'" '-' | tr '"' '-' | tr ' ' '_' | tr '(' '-' | tr ')' '-' | sed 's/_-_/-/g')
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
