#!/usr/bin/env bash

if [[ `uname` == 'Darwin' ]]; then
  /System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend
else
  i3lock --color=212121
  exit 0
fi
