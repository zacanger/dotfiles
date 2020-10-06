#!/usr/bin/env bash
set -e

Xephyr :4 -ac -screen 800x600 &
sleep 2
DISPLAY=:4 "$@" &
