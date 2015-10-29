#!/bin/bash

# Fehlerabfrage wenn cd nicht geht
# Fehlerabfrage wenn xdg-open nicht geht (kein Filehandler, e.g. $HOME/cube

[[ $0 = /* ]] && self="$0" || self="$PWD/${0#./}"
selfdir=${self%/*}

if [[ $1 == --dir ]]; then
	dir="$2"
	shift 2
else
	dir="$HOME"
fi

cd "$dir"
[[ "$dir" !=  / ]] && files='..'

shopt -s nullglob
files+=(*)

showpath=${PWD/#$HOME/"~"}

[[ "$showpath" == */*/* ]] && (( ${#showpath} >= 14 )) && showpath=".../${showpath##*/}"

while :; do
	file=$(printf '%s\n' "${files[@]}" | dmenu -i -p "open: $showpath" "$@") 
	status=$?
	(( $status != 0 )) && exit $status

	if [[ ! -e "$file" ]]; then
		echo 'Error: File does not exist!' | dmenu -p open -l 1 "$@" >/dev/null
		status=$?
		(( $status != 0 )) && exit $status
		dir=
	fi

	if [[ "$file" == ".." ]]; then
		dir="${dir%/*}"
		[[ -z "$dir" ]] && dir=/
		if cd "$dir" > /dev/null 2>&1; then
			"$self" --dir "$dir"
			exit $?
		fi
	elif [[ -d "$file" ]]; then
		[[ "$dir" == / ]] && dir=
		if cd "$dir/$file" > /dev/null 2>&1; then
			"$self" --dir "$dir/$file"
			exit $?
		fi
	elif [[ "$file" ]]; then
		xdg-open "$dir/$file"
		exit 0
	fi
done
