#!/bin/bash

#title :Screen recorder
#description :Records Screen Cast with Sound
#author :Kris Occhipinti
#site :http://filmsbykris.com
#date :Tue Jun 3 12:23:23 EDT 2014
#version :5
#usage :./pfff.sh
#notes :Will most likely need to be tweeked for difference systems
#License :GPLv3 http://www.gnu.org/licenses/gpl-3.0.html

#cd $HOME/Videos/tutorials/original
SavePath=$(zenity --file-selection --save --confirm-overwrite)
echo "Saving video to $szSavePath"

INFO=$(xwininfo -frame)

WIN_GEO=$(echo "$INFO"|grep -e "Height:" -e "Width:"|cut -d\: -f2|tr "\n" " "|awk '{print $1 "x" $2}')
WIN_POS=$(echo "$INFO"|grep "upper-left"|head -n 2|cut -d\: -f2|tr "\n" " "|awk '{print $1 "," $2}')


#ffmpeg -f alsa -ac 2 -i pulse -f x11grab -s $WIN_GEO -r 15 -i :0.0+$WIN_POS -r 15 -acodec pcm_s16le -sameq "$SavePath.avi"
avconv -f x11grab -s $WIN_GEO -r 15 -i :0.0+$WIN_POS -r 15 -qscale 3 "$SavePath.1.avi"&
#arecord "$SavePath.wav" -f cd -r48000
arecord -D "hw:3,0" -f cd -r48000 "$SavePath.wav" -c 1 

killall avconv

#echo "$WIN_GEO -i :0.0+$WIN_POS -acodec"
#echo "$WIN_POS"

avconv -i "$SavePath.1.avi" -i "$SavePath.wav" -vcodec copy -acodec copy "$SavePath.avi"

rm "$SavePath.wav"
rm "$SavePath.1.avi"
