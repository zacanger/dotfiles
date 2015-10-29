#!/bin/bash

tweet_user="changeme"
tweet_pass="changeme"

while :; do
	tweet=$(dmenu -p tweet "$@" < /dev/null)
	status=$?
	(( $status != 0 )) && exit $status

	if (( ${#tweet} > 140 )); then
		echo "Error: Tweet is too long! (${#tweet}/140)" | dmenu -l 1 -p tweet "$@" > /dev/null
	else
		curl -s -u "$tweet_user:$tweet_pass" --data-urlencode status="$tweet" http://twitter.com/statuses/update.xml -o /dev/null
		exit 0
	fi

done
