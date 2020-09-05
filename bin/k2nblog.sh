#!/usr/bin/env bash

names.sh .

for f in *; do
  aunpack "$f"
  rm "$f"
done

names.sh .

find . -type f -name 'k2nblog*.url' -exec rm {} +
find . -type f -name 'thumbs.db' -exec rm {} +

for f in *; do
  new_name=$(echo "$f" | sed -r 's/(_-)?(www.)?k2nblog\.com(-)?//')
  if [ "$f" != "$new_name" ]; then
    mv "$f" "$new_name"
  fi
done

# TODO:
# strip www.k2nblog.com comment from every audio file
# convert m4as, flacs, or whatever to mp3
