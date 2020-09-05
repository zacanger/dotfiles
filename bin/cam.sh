#!/usr/bin/env bash

[[ -t 1 ]] || { exec >/dev/null; exec 2>&1; }
ffplay -f v4l2 -framerate 25 -video_size 640x480 -i "${1:-/dev/video0}" -vf hflip
