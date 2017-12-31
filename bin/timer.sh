#!/usr/bin/env bash

main() {
  sleep $@
  mpv --really-quiet ~/.alarm/alarm.ogg
}

main $@ &
