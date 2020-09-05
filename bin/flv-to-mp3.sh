#!/usr/bin/env bash

for a in ./*.flv; do
  ffmpeg -i "$a" -f mp3 -ar 44100 -ac 2 -ab 192k -y -acodec copy "${a/.flv/.mp3}"
  rm "$a"
done
