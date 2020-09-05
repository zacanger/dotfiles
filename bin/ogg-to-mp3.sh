#!/usr/bin/env bash

for a in ./*.ogg; do
  < /dev/null ffmpeg -i "$a" "${a[@]/%ogg/mp3}"
  rm "$a"
done
