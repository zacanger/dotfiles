#!/usr/bin/env bash
set -e

echo fs.inotify.max_user_watches=1000000 >> /etc/sysctl.d/99-sysctl.conf
sysctl -p
