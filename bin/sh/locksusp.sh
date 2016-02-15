#!/bin/bash

if [[ "$UID" != "0" ]]; then
	echo 'locksusp must be run as root'
	exit 1
fi

exec 3< <(xscreensaver-command -watch)

xscreensaver-command -lock

while read line; do
	case "$line" in
		*LOCK*)
			break
			;;
	esac
done <&3

exec 3<&-

susp
