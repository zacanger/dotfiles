#!/usr/bin/env bash

thingtogif() {
  local name="$1"
  echo "${name%.*}.gif"
}

if [ "$2" = "" ]; then
  ffmpeg -i $1 -pix_fmt rgb24 -f gif "$(tthingtogif "$1")"
else
  ffmpeg -i $1 -pix_fmt rgb24 -f gif $2
fi
