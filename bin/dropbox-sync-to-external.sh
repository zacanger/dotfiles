#!/usr/bin/env bash

set -e

for dir in /media/z/*; do
  /usr/bin/rsync -a --inplace /home/z/Dropbox/ "$dir/Dropbox/" --delete --info=progress2
done

sync
