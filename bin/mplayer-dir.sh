#!/usr/bin/env bash
set -e

mplayer -playlist <(find "$PWD" -type f | sort)
