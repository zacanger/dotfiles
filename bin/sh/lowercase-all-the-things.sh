#!/usr/bin/env bash

for f in *; do b=$(echo "$f" | tr '[A-Z]' '[a-z]'); mv "$f" "$b"; done

