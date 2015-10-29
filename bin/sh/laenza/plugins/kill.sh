#!/bin/bash

signals=(TERM INT HUP KILL STOP CONT USR1 USR2)

while :; do
	proc=$(ps x -o comm= | sort | uniq | dmenu -p kill -i "$@")
	status=$?
	(( $status != 0 )) && exit $status

	signal=$(printf '%s\n' "${signals[@]}" | dmenu -p kill -i "$@")
	status=$?
	if (( $status == 0 )); then
		pids=$(pgrep "$proc")
		[[ "$pids" ]] &&  kill -SIG${signal} ${pids}
		exit 0
	fi
done
