#!/usr/bin/env bash
set -e

sound() {
    play -q -n synth 0.05 sin 1000
}

loop() {
    for i in {1..4}; do
        sound
    done
    sleep 0.5
}

if [[ $# -eq 0 ]]; then
    echo "it's now $(date)"
    echo alarm date and time?
    read date
else
    date="$1"
fi

echo okay! alarm happening at $(date --date="$date")

sleep $(( $(date --date="$date" +%s) - $(date +%s) ))

echo "wake up!"

while true; do
    loop
done
