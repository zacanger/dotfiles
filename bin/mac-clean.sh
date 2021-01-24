#!/usr/bin/env bash

sudo -v

brew cleanup --prune=all

sqlite3 \
    ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* \
    'delete from LSQuarantineEvent'

gem cleanup

docker system prune -af
docker-clean.sh

npm cache clear -f

clear-dns-cache.sh

sudo rm -rfv /private/var/log/asl/*.asl
sudo rm -rfv /Library/Logs/DiagnosticReports/*
sudo rm -rfv ~/.Trash/*
sudo rm -rfv /Library/Caches/*
sudo rm -rfv /System/Library/Caches/*
sudo rm -rfv ~/Library/Caches/*
sudo rm -rfv /cores/core.*

gfind "$HOME" -name '.DS_Store' -type f -delete

gfind "$HOME" -maxdepth 1 -name '*hist*' -delete
gfind "$HOME" -maxdepth 1 -name '*hst' -delete
rm "$HOME/.viminfo"

sudo purge

sync
