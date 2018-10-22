#!/usr/bin/env bash

for i; do
  touch "$i"
  chmod a+x "$i"
done

${EDITOR:-vim} "$@"
