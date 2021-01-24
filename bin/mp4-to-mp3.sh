#!/usr/bin/env bash
set -e

for a in ./*.mp4; do
    ffmpeg -i "$a" -map 0:a -vn -b:a 128k    "${a/.mp4/.mp3}"
    rm "$a"
done
