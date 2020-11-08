#!/usr/bin/env bash
set -e

for file in ./*.wma; do
  < /dev/null ffmpeg -i "${file}" -acodec libmp3lame -ab 192k "${file/.wma/.mp3}"
  rm "$file"
done
