#!/usr/bin/env bash

# example thrown together for an after-hours lecture
# on the basics of using the terminal, bash, etc.
# simpler version:
# du -sh ./*
# (yeah, that's it.)

echo "what directory are we checking?"
read dir
du -sh "$dir"

