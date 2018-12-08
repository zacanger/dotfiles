#!/usr/bin/env bash

sound() {
  play -q -n synth 0.05 sin 1000
}

loop() {
  for i in {1..4}; do
    sound
  done
  sleep 0.5
}

while :; do
  loop
done
