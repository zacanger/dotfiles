#!/usr/bin/env bash

echo 'start (hh:mm:ss.0)'
read -r start
echo end
read -r end
echo input
read -r input
echo output
read -r output

ffmpeg -ss "$start" -i "$input" -c copy -t "$end" "$output"
