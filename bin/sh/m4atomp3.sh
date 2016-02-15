#!/bin/sh
timestamp=$(date +'%Y%m%d-%H%M%S')
#dst_dir=/run/shm/0ebf87e0591d0d4b31d182e259de277345e23188/music
dst_dir=/home/zacanger/Music
mp3_opt="-acodec libmp3lame -ac 2 -ar 44100 -b 320k"
while read i; do
	dst=$dst_dir/${timestamp}_$(echo "$i" | sed -e's|/|_|g' -e's/ /_/g' -e's/\.m4a$/.mp3/' -e's/^\.//')
	ffmpeg -i "$i" $mp3_opt "$dst"
done