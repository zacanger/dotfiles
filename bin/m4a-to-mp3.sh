#!/usr/bin/env bash

for a in ./*.m4a; do
  < /dev/null ffmpeg -i "$a" -c:a libmp3lame -b:a 96k "${a[@]/%m4a/mp3}"
  rm "$a"
done
