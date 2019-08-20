#!/usr/bin/env bash

for dir in /media/z/*; do
  /usr/bin/rsync -azP /home/z/Dropbox/ $dir/Dropbox/ --delete
done
