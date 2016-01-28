#!/bin/bash

## reveals packed file types inside another file
# (c) 2012 F00L.DE

## check for arguments
# 1 - FILENAME
if [ ! $1 ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

# get file size; needed for proper count calculation
size=$(stat -c%s "$1")
output="reveal.tmp"
echo -e "\nRevealing file types inside \"$1\" ($size bytes)"

# loop byte by byte
for ((i=0;i<size;i++)); do

  # extract bytes from file (cut first i bytes)
  dd if="$1" of="/tmp/$output" bs=1 skip=$i count=$[$size-$i] &> /dev/null

  # use 'file'-tool to analyze magic
  type=$(file -b /tmp/$output)

  # output result without 'data'-entries
  if [ "$type" != "data" ]; then
    printf "%7d : %s\n" "$i" "$type"
  fi

done

# remove temp file
rm "/tmp/$output"

