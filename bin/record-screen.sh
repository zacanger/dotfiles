#!/usr/bin/env bash

OFFS=""
SIZE=$(xdpyinfo | grep dimensions | awk '{print $2;}')

ffmpeg -y \
  -f x11grab \
  -framerate 30 \
  -s "$SIZE" \
  -i ":0.0$OFFS" \
  ~/Downloads/out.mkv
