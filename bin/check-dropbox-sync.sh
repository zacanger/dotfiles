#!/usr/bin/env bash

if [[ `uname -a` == *"Arch"* ]]; then
  dropbox_cmd=dropbox-cli
else
  dropbox_cmd=dropbox
fi
while true; do
  sleep 10
  clear
  $dropbox_cmd status
done
