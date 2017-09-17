#!/bin/bash

main() {
    sleep $@
    mpv --really-quiet ~/.alarm/alarm.ogg
}

main $@ &

