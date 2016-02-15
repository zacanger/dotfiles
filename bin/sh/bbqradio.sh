#!/bin/bash
pkill -9 mpg123
# bbqradio

INPUT=/tmp/input.$$

dialog --backtitle "BBQradio" --title "Live Radio Stations" --menu "Ctrl-C to stop the radio" 20 55 15 \
	A SWR1 \
	B RadioIn \
	C TraceRadio \
	D SonicUniverse \
	E Frisky \
	F Bassdrive \
	G "Suburbs of Goa" \
	H TraxxHouse \
	I TraxxElectro \
	J TraxxDeep \
	K "Doomed Dark" \
	L "Beat Blender" \
	M "Boot Liquor" \
	N "Black Rock FM" \
	O "Cliphop idm" \
	P Covers \
	Q Digitalis \
	R "Illinois Street Lounge" \
	S "Indie Pop Rocks" \
	T PopTron \
	U Underground \
	V "Radio F Nuremberg" \
	W Deutschlandfunk \
	X "Blues Radio" \
	Y "Coolradio Jazz" \
	Z "Jazzradio" \
	a "Flower Power" \
	b "Radiolla" \
	c "Jiraffe Jazz" \
	d "Volta Ambient" \
	e "Equalyza Hip Hop" \
	f "Ilma Classic" \
	x "Minimize Radio" \
	q "Turn off Radio" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	A) cmd="mpg123 -C -q -@ http://mp3-live.swr.de/swr1bw_s.m3u"  ;;
	B) cmd="mpg123 -C -q -@ http://4broadcast.de/radioin.m3u"  ;;
	C) cmd="mpg123 -C -q -@ http://tranceradio.ch/listen.m3u"  ;;
	D) cmd="mpg123 -C -q http://voxsc1.somafm.com:8600" ;;
	E) cmd="mpg123 -C -q -@ http://www.friskyradio.com/frisky.m3u"  ;; 
	F) cmd="mpg123 -C -q -@ http://shouthostdirect13.streams.bassdrive.com:8202" ;;
	G) cmd="mpg123 -C -q http://streamer-dtc-aa03.somafm.com:80/stream/1018"  ;;
	H) cmd="mpg123 -C -q http://broadcast.infomaniak.ch/traxx002-low.mp3"  ;;
	I) cmd="mpg123 -C -q http://broadcast.informaniak.ch/traxx003-low.mp"  ;;
	J) cmd="mpg123 -C -q http://broadcast.informaniak.ch/traxx013-low.mp3"  ;;
	K) cmd="mpg123 -C -q http://voxsc1.somafm.com:8300" ;;
	L) cmd="mpg123 -C -q http://voxsc1.somafm.com:8384" ;;
	M) cmd="mpg123 -C -q http://voxsc1.somafm.com:7000" ;;
	N) cmd="mpg123 -C -q http://voxsc1.somafm.com:8040" ;;
	O) cmd="mpg123 -C -q http://voxsc1.somafm.com:8062" ;;
	P) cmd="mpg123 -C -q http://voxsc1.somafm.com:8700" ;;
	Q) cmd="mpg123 -C -q http://voxsc1.somafm.com:8900" ;;
	R) cmd="mpg123 -C -q http://voxsc1.somafm.com:8500" ;;
	S) cmd="mpg123 -C -q http://voxsc1.somafm.com:8090" ;;
	T) cmd="mpg123 -C -q http://voxsc1.somafm.com:2200" ;;
	U) cmd="mpg123 -C -q http://voxsc1.somafm.com:8880" ;;
	V) cmd="mpg123 -C -q http://webradio.radiof.de:8000/" ;;
	W) cmd="mpg123 -C -q -@ http://www.dradio.de/streaming/dlf.m3u" ;;
	X) cmd="mpg123 -C -q http://205.164.62.21:8030/" ;;
	Y) cmd="mpg123 -C -@ http://www.coolradio.de/streams/cooljazz-128.m3u" ;;
	Z) cmd="mpg123 -C -@ http://www.jazzradio.net/docs/stream/jazzradio.pls" ;;
	a) cmd="mpg123 -C -@ http://ams02.egihosting.com:5050/" ;;
	b) cmd="mpg123 -C -@ http://air.radiolla.com/radiolla192k" ;;
	c) cmd="mpg123 -C -@ http://air.radiolla.com/jiraffe192k" ;;
	d) cmd="mpg123 -C -@ http://air.radiolla.com/volta192k" ;;
	e) cmd="mpg123 -C -@ http://air.radiolla.com/equalyza192k" ;;
	f) cmd="mpg123 -C -@ http://air.radiolla.com/ilma192k" ;;
	q) cmd="pkill -9 mpg123" ;;
	x) exit 0 ;;
esac

eval exec $cmd
