#!/bin/bash

# TODO maybe use dbus instead, so we're also able to rate, volume, etc.

while :; do
	running=1
	play=
	show=
	controls=

	if ! pgrep -x banshee-1 >/dev/null; then
		play="play"
		show=""
		running=
	elif [[ $(banshee --query-current-state) == "current-state: playing" ]]; then
		show="show quit"
		controls="stop prev next info"
		if [[ $(banshee --query-can-pause) == "can-pause: true" ]] ; then
			play="pause"
		else
			play=""
		fi
	else
		show="show quit"
		play="play"
	fi

	options=($play $controls $show) # leave them unquoted!

	do=$(printf '%s\n' "${options[@]}" | dmenu -i -p media "$@") 
	status=$?
	(( $status != 0 )) && exit $status
	
	case $do in
		play)
			if ! [[ "$running" ]]; then
				echo "Starting banshee..."
				( banshee --hide --no-present | while read line; do echo "$line"; [[ $line == *"nereid Client Started"* ]] && echo "Hitting play!" && banshee --play; done ) &
			else
				banshee --play
			fi
			exit 0
		;;
		pause)
			banshee --pause
			exit 0
		;;
		show)
			banshee --show
			exit 0
		;;
		stop)
			banshee --stop
			exit 0
		;;
		prev)
			banshee --previous
			exit 0
		;;
		next)
			banshee --next
			exit 0
		;;
		info)
			info=("$(banshee --query-artist)" "$(banshee --query-album)" "$(banshee --query-title)")
			printf '%s\n' "${info[@]}" | dmenu -l 3 -i -p media "$@" > /dev/null
			exit 0
		;;
		quit)
			killall banshee-1 2>/dev/null
			exit 0
		;;
	esac
done
