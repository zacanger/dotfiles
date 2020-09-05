#!/bin/sh

input="$1"
output="$2"
ffmpeg -i "$input" -vcodec libx265 -crf 28 "$output"
