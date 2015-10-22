#!/bin/bash
# play the last stream of /usr/local/bin/tinyradio

STREAM=(`cat ~/.playstream`)

if [ "$(pidof mpg123)" ] ; then killall mpg123; exit
	else
	if [ $DISPLAY ]; then 
		echo "Buffering $STREAM ..." | osd_cat  -s 1 -S black -p top -A center -d 10 -c grey -l 1 
	fi
	mpg123 -C -@ $STREAM
fi

# please also read the manpage of mpg123 for options like buffer size, cache...
