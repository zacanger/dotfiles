#!/usr/bin/env bash

mpv *
exit

# This script plays videos from a number of websites in mpv,
# including YouTube, Vimeo, SoundCloud, etc
#
# Playlists are also supported.

set -m
cookies_dir="$(mktemp -d /tmp/youtube-dl_mpv.XXXX)"
cookies_file="${cookies_dir}/cookies"
user_agent="$(youtube-dl --dump-user-agent)"
fifo=$(mktemp -u)
fifo2=$(mktemp -u)
mkfifo $fifo
mkfifo $fifo2

youtube-dl --user-agent="$user_agent" \
  --cookies="$cookies_file" \
  --get-url \
  --ignore-errors \
  "$1" > $fifo2 &

read -r url < $fifo2

mpv --idle \
  --input-file $fifo \
  --cookies \
  --cookies-file="$cookies_file" \
  --user-agent="$user_agent" \
  "$url" &
mpv_pid=%-

coproc while read -r url; do
echo "loadfile \"$url\" append" > $fifo
done < $fifo2

fg $mpv_pid

rm $fifo
rm $fifo2
rm -rf "$cookies_dir"
