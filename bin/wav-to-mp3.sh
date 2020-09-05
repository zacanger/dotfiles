#!/usr/bin/env bash

for a in ./*.wav; do
  lame -V2 "$a" "${a/.wav}.mp3"
  # rm "$a"
done
