#!/usr/bin/env bash
set -e

for a in ./*.ogg; do
  < /dev/null ffmpeg -i "$a" "${a[@]/%ogg/mp3}"
  rm "$a"
done
