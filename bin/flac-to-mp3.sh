#!/usr/bin/env bash
set -e

for a in ./*.flac; do
    < /dev/null ffmpeg -i "$a" -qscale:a 0 "${a[@]/%flac/mp3}"
    rm "$a"
done
