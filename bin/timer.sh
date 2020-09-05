#!/usr/bin/env bash

alarmpath=$HOME/Dropbox/z/.alarm.mp3

main() {
  sleep "$@"
  mpv --really-quiet "$alarmpath"
}

main "$@" &
