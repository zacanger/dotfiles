#!/usr/bin/env bash

if [[ $(uname) == 'Darwin' ]]; then
  /System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend
else
  if hash xtrlock 2>/dev/null; then
    xtrlock -b
  elif hash slock 2>/dev/null; then
    slock
  fi
fi
