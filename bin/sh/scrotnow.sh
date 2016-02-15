#!/bin/sh
scrot '%Y%m%d%s$wx$h.png' -e 'mv $f ~/images/' 
feh ~/images/$f
