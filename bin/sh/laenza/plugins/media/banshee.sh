#!/bin/bash

# TODO maybe use dbus instead, so we're also able to rate, volume, etc.

dbus() {
	[[ $1 == -p ]] && pr=--print-reply && shift
	interface="$1"
	method="$2"
	shift 2

	dbus-send \
		--session \
		--type=method_call \
		$pr \
		--dest=org.bansheeproject.Banshee \
		"/org/bansheeproject/Banshee/$interface" \
		org.bansheeproject.Banshee.$interface.$method \
		"$@"
}



while :; do
	running=1
	play=
	show=
	controls=

	if ! pgrep -x banshee-1 >/dev/null; then
		play="play"
		show=""
		running=
	elif dbus -p PlayerEngine GetCurrentState | grep -q 'string "playing"'; then
		show="show quit"
		controls="stop prev next rate volume info"
		if dbus -p PlayerEngine GetCanPause | grep -q 'boolean true'; then
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
				(
					banshee --no-present | while read line; do
					 	if [[ $line == *"nereid Client Started"* ]]; then
							dbus PlayerEngine Play
						fi
					done
				) &
			else
				dbus PlayerEngine Play
			fi
			exit 0
		;;
		pause)
			dbus PlayerEngine Pause
			exit 0
		;;
		show)
			dbus ClientWindow Present
			exit 0
		;;
		stop)
			dbus PlayerEngine Close
			exit 0
		;;
		prev)
			dbus PlaybackController Previous boolean:false
			exit 0
		;;
		next)
			dbus PlaybackController Next boolean:false
			exit 0
		;;
		volume)
			volume=$(dbus -p PlayerEngine GetVolume | awk '/uint16/{ print $2 }')
			newvolume=$(printf '%s\n' 0 {1..10}0 | dmenu -p "vol [$volume]" "$@")
			dbus PlayerEngine SetVolume uint16:$newvolume
			exit 0
		;;
		rate)
			rating=$(dbus -p PlayerEngine GetRating | awk '/byte/{ print $2 }')
			newrating=$(printf '%s\n' {0..5} | dmenu -p "rate [$rating]" "$@")
			dbus PlayerEngine SetRating byte:$newrating
			exit 0
		;;

		info)
			declare -A infos
			declare -A names
			names[local-path]="path"
			names[artist]="artist"
			names[name]="title"
			names[album]="album"
			names[genre]="genre"

			# Oh yah, parsing shit via awk... this is subject to break.
			dbus -p PlayerEngine GetCurrentTrack | awk '
				/^ *string/ {
					gsub(/^"|"$/,"",$2)
					string=$2
				}
				/^ *variant/ {
					gsub(/^"|"$/,"",$3)
					value=$3
				}
				/)/ {
					print(string" "value)
				}' \
			| while read name value; do
				[[ ${names[$name]} ]] && echo "${names[$name]}: $value"
			done | dmenu -l 4 -i -p media "$@" > /dev/null
			exit 0
		;;
		quit)
			killall banshee-1 2>/dev/null
			exit 0
		;;
	esac
done
