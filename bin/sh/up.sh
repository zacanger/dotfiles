#!/bin/bash

if [ -z "$UP_CHECKSUM" ]; then
  UP_CHECKSUM="cksum"
fi

if [ -z "$UP_INTERVAL" ]; then
  UP_INTERVAL=1
fi

monitors=()
while [ "$1" != "--" ]; do
  monitors+=("$1")
  shift
done

shift
run_command="$@ &"
last_hash=""
up_pid=0

function up-checksum {
  find "${monitors[@]}" -type f -exec $UP_CHECKSUM {} \; | sort | $UP_CHECKSUM
}

function up-start-process {
  eval "$run_command"
  up_pid=$!
}

function up-stop-process {
  kill "$up_pid" 2> /dev/null
}

function up-sigint-handler {
  up-stop-process
  exit $?
}

trap up-sigint-handler INT

while :; do
  current_hash="$(up-checksum)"

  if [ -z "$last_hash" ]; then
    up-start-process
  elif [ "$current_hash" != "$last_hash" ]; then
    up-stop-process
    up-start-process
  fi

  last_hash="$current_hash"
  sleep $UP_INTERVAL
done
