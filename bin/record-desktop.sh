#!/bin/bash
#
# record your desktop using ffmpeg

dimensions=$(xdpyinfo | grep 'dimensions:' | awk '{print $2}')

if [[ $1 ]]; then
    output="$1"
else
    output="/tmp/out.mpg"
fi

ffmpeg -f x11grab -s $dimensions -r 25 -i $DISPLAY -sameq $output
