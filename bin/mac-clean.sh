#!/usr/bin/env bash

# Your terminal program will need full disk access
# for this to really work.

# see also
# https://github.com/mac-cleanup/mac-cleanup-py/blob/main/mac_cleanup/default_modules.py

sudo -v

del_paths=(
    "$HOME/.Trash/*"
    "$HOME/.cache/youtube-dl/*"
    "$HOME/.cache/yt-dlp/*"
    "$HOME/.local/share/ranger/*"
    "$HOME/.viminfo"
    "$HOME/.z-trash/*"
    "$HOME/Library/Caches/*"
    "$HOME/Library/Logs/*"
    /Library/Caches/*
    /Library/Logs/*
    /System/Library/Caches/*
    /cores/core.*
    /var/log/*
    /var/logs/*
    /var/spool/cups/c0*
    /var/spool/cups/cache/job.cache*
    /var/spool/cups/tmp/*
    "$HOME/Library/Containers/com.apple.Safari/Data/Library/Caches/*"
    /private/var/folders/ry/*/*/com.apple.Safari/com.apple.Safari/com.apple.metal/*/libraries.data
    /private/var/folders/ry/*/*/com.apple.Safari/com.apple.Safari/com.apple.metal/*/libraries.maps
    "$HOME/Library/Containers/io.te0.WebView/Data/Library/Caches/WebKit"
    "$HOME/Library/Safari/CloudHistoryRemoteConfiguration.plist"
)
for p in "${del_paths[@]}"; do
    sudo rm -rfv "$p"
done

for x in $(ls ~/Library/Containers/); do
    sudo rm -rfv "$HOME/Library/Containers/$x/Data/Library/Caches/*"
    sudo rm -rfv "$HOME/Library/Containers/$x/Data/Library/Logs/*"
done

gfind "$HOME" -name '.DS_Store' -type f -delete
gfind "$HOME" -maxdepth 1 -name '*hist*' -delete
gfind "$HOME" -maxdepth 1 -name '*hst' -delete

sqlite3 \
    ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* \
    'delete from LSQuarantineEvent'

brew cleanup --prune=all
gem cleanup
if [[ "$1" == "-d" ]]; then docker-clear.sh; fi
npm cache clear -f
rm -rfv "$HOME/.npm"
clear-dns-cache.sh

sudo purge
sync
