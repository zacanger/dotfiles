#!/bin/bash
# written by pidsley
# borked by bacon

STREAM_FILE=/usr/local/share/radiolist

[[ ! -f "$STREAM_FILE" ]] && echo "$STREAM_FILE does not exist" && exit 1

array=( $(cat "$STREAM_FILE") )

select opt in "${array[@]}"; do
    [[ $1 =~ ^-r ]] && streamripper "$opt" &
    echo "Caching $opt ... be patient!"
    # this makes the last stream available in 'playstream'
    echo  "$opt" > ~/.playstream
    if [ $DISPLAY ]; then
    echo "Buffering $opt ..." | osd_cat  -s 1 -S black -p top -A center -d 10 -c grey -l 1
    fi
    mpg123 -C -@ "$opt"
    break
done
