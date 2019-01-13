#!/usr/bin/env bash

if [[ $1 == '-l' ]]; then
  curl -s https://status.github.com/api/messages.json | jq .
else
  curl -s https://status.github.com/api/status.json | jq .status
fi
