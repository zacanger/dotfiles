#!/bin/bash

hist="$HOME/.laenza/wwwhistory"
[[ ! -e $hist ]] && touch "$hist"

url=$(tac "$hist" | dmenu -i -p www "$@") 
status=$?
(( $status != 0 )) && exit $status

echo "$url" >> "$hist"

[[ $url != *://* ]] && url="http://$url" 
xdg-open "$url" > /dev/null 2>&1 &
