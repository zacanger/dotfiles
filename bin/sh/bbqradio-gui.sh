#!/bin/bash
pkill -9 mpg123
# bbqradio-gui

action=$(yad --width 300 --entry --title "LinuxBBQ Pocket Radio" \
    --image=gnome-mixer \
    --button="Turn off:3" \
    --button="Music On Console:2" \
    --button="gtk-ok:0" --button="gtk-close:1" \
    --text "Choose action:" \
    --entry-text \
	"01 SWR1" \
	"02 RadioIn" \
	"03 TraceRadio" \
	"04 Sonic Universe" \
	"05 Frisky" \
	"06 Bassdrive" \
	"07 Suburbs of Goa" \
	"08 TraxxHouse" \
	"09 TraxxElectro" \
	"10 TraxxDeep" \
	"11 Doomed Dark" \
	"12 Beat Blender" \
	"13 Boot Liquor" \
	"14 Black Rock FM" \
	"15 Cliphop idm" \
	"16 Covers" \
	"17 Digitalis" \
	"18 Illinois Street Lounge" \
	"19 Indie Pop Rocks" \
	"20 PopTron" \
	"21 Underground" \
	"22 Radio F Nuremberg" \
	"23 Deutschlandfunk" \
	"24 Blues Radio" \
	"25 Coolradio Jazz" \
	"26 Jazzradio" \
	"27 Flower Power" \
	"28 Radiolla" \
	"29 Jiraffe Jazz" \
	"30 Volta Ambient" \
	"31 Equalyza Hip Hop" \
	"32 Ilma Classic" \
)
ret=$?

[[ $ret -eq 1 ]] && pkill -9 mpg123 && exit 0

if [[ $ret -eq 2 ]]; then
    x-terminal-emulator -e mocp -T moca_theme &
    exit 0
fi

if [[ $ret -eq 3 ]]; then
	pkill -9 mpg123 &
	exit 0
fi

case $action in
	01*) cmd="mpg123 -C -q -@ http://mp3-live.swr.de/swr1bw_s.m3u"  ;;
	02*) cmd="mpg123 -C -q -@ http://4broadcast.de/radioin.m3u"  ;;
	03*) cmd="mpg123 -C -q -@ http://tranceradio.ch/listen.m3u"  ;;
	04*) cmd="mpg123 -C -q http://voxsc1.somafm.com:8600" ;;
	05*) cmd="mpg123 -C -q -@ http://www.friskyradio.com/frisky.m3u"  ;; 
	06*) cmd="mpg123 -C -q -@ http://shouthostdirect13.streams.bassdrive.com:8202" ;;
	07*) cmd="mpg123 -C -q http://streamer-dtc-aa03.somafm.com:80/stream/1018"  ;;
	08*) cmd="mpg123 -C -q http://broadcast.infomaniak.ch/traxx002-low.mp3"  ;;
	09*) cmd="mpg123 -C -q http://broadcast.informaniak.ch/traxx003-low.mp"  ;;
	10*) cmd="mpg123 -C -q http://broadcast.informaniak.ch/traxx013-low.mp3"  ;;
	11*) cmd="mpg123 -C -q http://voxsc1.somafm.com:8300" ;;
	12*) cmd="mpg123 -C -q http://voxsc1.somafm.com:8384" ;;
	13*) cmd="mpg123 -C -q http://voxsc1.somafm.com:7000" ;;
	14*) cmd="mpg123 -C -q http://voxsc1.somafm.com:8040" ;;
	15*) cmd="mpg123 -C -q http://voxsc1.somafm.com:8062" ;;
	16*) cmd="mpg123 -C -q http://voxsc1.somafm.com:8700" ;;
	17*) cmd="mpg123 -C -q http://voxsc1.somafm.com:8900" ;;
	18*) cmd="mpg123 -C -q http://voxsc1.somafm.com:8500" ;;
	19*) cmd="mpg123 -C -q http://voxsc1.somafm.com:8090" ;;
	20*) cmd="mpg123 -C -q http://voxsc1.somafm.com:2200" ;;
	21*) cmd="mpg123 -C -q http://voxsc1.somafm.com:8880" ;;
	22*) cmd="mpg123 -C -q http://webradio.radiof.de:8000/" ;;
	23*) cmd="mpg123 -C -q -@ http://www.dradio.de/streaming/dlf.m3u" ;;
        24*) cmd="mpg123 -C -q http://205.164.62.21:8030/" ;;
	25*) cmd="mpg123 -C -@ http://www.coolradio.de/streams/cooljazz-128.m3u" ;;
	26*) cmd="mpg123 -C -@ http://www.jazzradio.net/docs/stream/jazzradio.pls" ;;
	27*) cmd="mpg123 -C -@ http://ams02.egihosting.com:5050/" ;;
	28*) cmd="mpg123 -C -@ http://air.radiolla.com/radiolla192k" ;;
	29*) cmd="mpg123 -C -@ http://air.radiolla.com/jiraffe192k" ;;
	30*) cmd="mpg123 -C -@ http://air.radiolla.com/volta192k" ;;
	31*) cmd="mpg123 -C -@ http://air.radiolla.com/equalyza192k" ;;
	32*) cmd="mpg123 -C -@ http://air.radiolla.com/ilma192k" ;;
	33*) cmd="mpg123 -C -@ " ;;
	34*) cmd="mpg123 -C -@ " ;;
	35*) cmd="mpg123 -C -@ " ;;
	99*) cmd="pkill -9 mpg123" ;;
	*) exit 1 ;;
esac

eval exec $cmd
