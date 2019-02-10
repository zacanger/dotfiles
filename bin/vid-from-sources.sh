#!/usr/bin/env bash

echo audio
read audio
echo image
read image
echo output
read output

ffmpeg -loop 1 -i "$image" -i "$audio" -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest "$output"
