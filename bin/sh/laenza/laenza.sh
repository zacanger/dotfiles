#!/bin/bash

[[ ! -d $HOME/.laenza ]] && mkdir "$HOME/.laenza"

# Find out where the script is located
[[ $0 = /* ]] && self="$0" || self="$PWD/${0#./}"
selfdir=${self%/*}
echo "$selfdir" > ~/.laenza/selfdir

# Add all executable .sh-files in plugins/ to dmenu_options
for plugin in "$selfdir"/plugins/*.sh; do
	if [[ -x "$plugin" ]]; then
		plugin=${plugin##*/} # basename 
		dmenu_options+=(${plugin%%.sh}) # cut ".sh"
	fi
done

while :; do
	# Display the main menu
	input=$(printf '%s\n' "${dmenu_options[@]}" | dmenu -p laenza "$@")
	(($? != 0)) && exit $?

	# Launch the plugin
	$selfdir/plugins/${input}.sh "$@"
	(($? == 0)) && exit $?
done
