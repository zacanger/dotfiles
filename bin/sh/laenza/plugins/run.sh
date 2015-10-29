#!/bin/bash

appcache=$HOME/.laenza/appcache

IFS=: dirs=($PATH)

uptodate() {
	[[ -f "$appcache" ]] || return 1
	for dir in "${dirs[@]}"; do
		[[ "$dir" -nt "$appcache" ]] && return 1
	done
}

if ! uptodate; then
	find "${dirs[@]}" \( -type f -o -type l \) -executable -printf '%f\n'  | sort | uniq > "$appcache"
fi

app=$(dmenu -i -p run "$@" < "$appcache")
status=$?
(( $status != 0 )) && exit $status

bash -c "$app" &
