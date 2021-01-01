#!/usr/bin/env bash
set -e

for a in ./*.wav; do
  lame -V2 "$a" "${a/.wav}.mp3"
  rm "$a"
done
