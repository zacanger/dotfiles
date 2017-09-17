#!/usr/bin/env bash

# rotate video by 90 degrees clockwise
# usage: mplayer-rotate.sh somevideo.whatever
# change to rotate=2 or rotate=3 for 180 and 270 deg

mplayer -vf rotate=1 $1

