#!/usr/bin/env bash

if [[ $(uname) == 'Darwin' ]]; then
  /System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend
else
  if hash i3lock 2>/dev/null; then
    i3lock --color=212121
  elif hash xtrlock 2>/dev/null; then
    xtrlock -b
  elif hash slock 2>/dev/null; then
    slock
  fi
fi
