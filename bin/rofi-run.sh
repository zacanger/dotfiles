#!/usr/bin/env bash
set -e

rofi \
  -show run \
  -modi run \
  -location 7 \
  -width 25 \
  -lines 1 \
  -line-margin 0 \
  -line-padding 1 \
  -separator-style none \
  -font "Hack 10" \
  -columns 2 \
  -bw 0 \
  -disable-history \
  -hide-scrollbar \
  -color-window "#3d3d3d, #3d3d3d, #b1b4b3" \
  -color-normal "#3d3d3d, #d2d8cf, #3d3d3d, #a2a497, #fafbf8" \
  -color-active "#3d3d3d, #d2d8cf, #3d3d3d, #d2d8cf, #fafbf8" \
  -color-urgent "#3d3d3d, #d2d8cf, #3d3d3d, #77003d, #fafbf8" \
  -kb-row-select "Tab" \
  -kb-row-tab ""
