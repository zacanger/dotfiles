#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo 'names: convert filenames to lowercase and replace characters, recursively'
  echo 'usage: names path/to/directory'
  exit 0
fi

find "$1" -depth -name '*' | while read file; do
  directory=$(dirname "$file")
  oldfilename=$(basename "$file")
  # tr -d '[{}(),\!]' | tr -d "\'"
  newfilename=$(echo "$oldfilename" \
    | tr 'A-Z' 'a-z' \
    | tr ',' '_' \
    | tr '[' '-' \
    | tr ']' '-' \
    | tr "'" '-' \
    | tr '"' '-' \
    | tr ' ' '_' \
    | tr '(' '-' \
    | tr ')' '-' \
    | sed 's/_-_/-/g')

  if [ "$oldfilename" != "$newfilename" ]; then
    mv -i "$directory/$oldfilename" "$directory/$newfilename"
    echo ""$directory/$oldfilename" -> "$directory/$newfilename""
  fi
done
exit 0
