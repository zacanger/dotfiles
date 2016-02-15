#!/usr/bin/env bash

if [ ! -d output ]
then
  mkdir output
fi

convert -resize x16 -gravity center -crop 16x16+0+0 $1 \
  -background transparent -transparent white -colors 256 output/favicon16.ico

convert -resize x32 -gravity center -crop 32x32+0+0 $1 \
  -background transparent -transparent white -colors 256 output/favicon32.ico

convert output/favicon16.ico output/favicon32.ico output/favicon.ico