#!/usr/bin/env bash
set -e

rofi -show run -modi run -location 7 -width 25 \
  -lines 1 -line-margin 0 -line-padding 1 \
  -separator-style none -font "Hack 10" -columns 2 -bw 0 \
  -disable-history \
  -hide-scrollbar \
  -color-window "#222222, #222222, #b1b4b3" \
  -color-normal "#222222, #b1b4b3, #222222, #005577, #b1b4b3" \
  -color-active "#222222, #b1b4b3, #222222, #007763, #b1b4b3" \
  -color-urgent "#222222, #b1b4b3, #222222, #77003d, #b1b4b3" \
  -kb-row-select "Tab" -kb-row-tab ""
