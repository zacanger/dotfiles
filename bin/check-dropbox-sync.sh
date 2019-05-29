#!/usr/bin/env bash

if [[ `uname -a` == *"Arch"* ]]; then
  dropbox_cmd=dropbox-cli
else
  dropbox_cmd=dropbox
fi
while true; do
  $dropbox_cmd status
  sleep 60
  clear
done
