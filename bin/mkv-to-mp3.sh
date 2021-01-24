#!/usr/bin/env bash
set -e

for a in ./*.mkv; do
    ffmpeg -i "$a" -map 0:a -vn -b:a 128k    "${a/.mkv/.mp3}"
    rm "$a"
done
