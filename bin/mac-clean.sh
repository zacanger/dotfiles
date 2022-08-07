#!/usr/bin/env bash

# Your terminal program will need full disk access
# for this to really work.

sudo -v

del_paths=(
    "$HOME/.Trash/*"
    "$HOME/.cache/youtube-dl/*"
    "$HOME/.local/share/ranger/*"
    "$HOME/.viminfo"
    "$HOME/.z-trash/*"
    "$HOME/Library/Caches/*"
    /Library/Caches/*
    /Library/Logs/DiagnosticReports/*
    /System/Library/Caches/*
    /cores/core.*
    /private/var/log/asl/*.asl
    /var/spool/cups/c0*
    /var/spool/cups/cache/job.cache*
    /var/spool/cups/tmp/*
    "$HOME/Library/Containers/com.apple.Safari/Data/Library/Caches/*"
    /private/var/folders/ry/*/*/com.apple.Safari/com.apple.Safari/com.apple.metal/*/libraries.data
    /private/var/folders/ry/*/*/com.apple.Safari/com.apple.Safari/com.apple.metal/*/libraries.maps
    "$HOME/Library/Containers/io.te0.WebView/Data/Library/Caches/WebKit"
    "$HOME/Library/Safari/History.db*"
    "$HOME/Library/Safari/RecentlyClosedTabs.plist"
    "$HOME/Library/Safari/CloudHistoryRemoteConfiguration.plist"
)
for p in "${del_paths[@]}"; do
    sudo rm -rfv "$p"
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
clear-dns-cache.sh

sudo purge
sync
