#!/usr/bin/env bash
set -e

pl=$(find . -type f -name '*.mp3')
mpv --vid=no --shuffle $pl
