#!/usr/bin/env bash
set -e

vol_root=''
linux_vol_root="/media/$USER"
mac_vol_root="/Volumes"

if [[ $(uname) == 'Darwin' ]]; then
    vol_root=$mac_vol_root
else
    vol_root=$linux_vol_root
fi

vol=$vol_root/$(ls "$vol_root" | fuzzy.py)

rsync -a -L --inplace "$HOME/Dropbox/" "$vol/backup/" --delete --info=progress2

date > "$vol/backup/sync-timestamp.txt"
sync
