#!/usr/bin/env bash

for dir in /media/z/*; do
  /usr/bin/rsync -az /home/z/Dropbox/ $dir/Dropbox/ --delete
done
