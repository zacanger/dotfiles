#!/bin/bash

selfdir=$(cat ~/.laenza/selfdir)
source "$selfdir/conf/calc.conf"

# perl -e 'print(eval(<STDIN>));'

case $calc in
	perl) calcargs=('-e' 'chomp(my $calc = <>); print(eval($calc));') ;;
esac

while :; do
	# Ask for the calculation
	term=$(dmenu -i -p calc "$@" < /dev/null) 
	status=$?
	(( $status != 0 )) && exit $status

	echo "$term" | $calc "${calcargs[@]}" 2>&1 | dmenu -l 1 -p "$term" "$@" > /dev/null
	status=$?
	(( $status == 0 )) && exit $status
done
