#!/usr/bin/env bash
set -e

main() {
    sleep "$@"
    play -n synth 2 sin 500 synth 2 sin fmod 1920 fade l 0 3 2.8 trim 0 1 repeat 3
}

main "$@" &
