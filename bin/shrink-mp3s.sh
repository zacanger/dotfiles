#!/usr/bin/env bash
set -e

for a in ./*.mp3; do
    old="$a-old.mp3"
    mv "$a" "$old"
    < /dev/null ffmpeg -i "$old" -codec:a libmp3lame -b:a 128k "$a"
    rm "$old"
done
