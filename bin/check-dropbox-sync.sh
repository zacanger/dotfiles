#!/usr/bin/env bash
set -e

if [[ $(uname -a) == *"Arch"* ]]; then
  dropbox_cmd=dropbox-cli
else
  dropbox_cmd=dropbox
fi
while true; do
  "$dropbox_cmd" status
  sleep 30
  clear
done
