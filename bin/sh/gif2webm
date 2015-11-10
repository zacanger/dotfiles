#!/bin/bash

if [ -z "$1" ]; then
    echo No input file. 1>&2
    exit 1
fi

if ! command -v ffmpeg &>/dev/null; then
    echo 1>&2 'ffmpeg not found. Aborting.'
    exit 1
fi

in="$1"
out="$(echo $1|sed 's/gif/webm/i')"

ffmpeg -i "$in" -c:v libvpx -crf 12 -b:v 500K "$out"
