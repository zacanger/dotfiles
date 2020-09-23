#!/usr/bin/env bash
set -e

input="$1"
output="$2"
ffmpeg -i "$input" -vcodec libx265 -crf 28 "$output"
