#!/bin/bash

if [ "$1" = "" ]
then
    echo "What do you want to search for?"
    read q
else
    q="$1"
fi


wget -q "http://labs.echonest.com/Uploader/search?q=$q&results=1000" -O-

echo "What is the 'trid' of the song you want?"
read trid

if [ "$trid" = "" ]
then
    echo "Nothing to do."
    echo "Good Bye."
    exit 0
fi 

url="$(wget -q "http://static.echonest.com/infinite_jukebox_data/$trid.json" -O-|tr '"' '\n'|grep mp3|grep http)"

echo "Would you like to play the song now? (Y/n)"
read play

if [ "$play" = "Y" ] || [ "$play" = "y" ] || [ "$play" = "" ]
then
    mplayer "$url"
fi

echo "Would you like to download the song? (Y/n)"
read download

if [ "$download" = "Y" ] || [ "$download" = "y" ] || [ "$download" = "" ]
then
    wget -c "$url"
fi

echo "Good bye."
