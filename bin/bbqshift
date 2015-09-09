#!/bin/bash
NR=1
NG=1
NB=1
NL=1
RR=1000
GG=1000
BB=1000
LL=1000
CON=`xrandr -q|grep con|cut -d " " -f 1`
echo Detected connectors are: $CON
echo Which do you want to manipulate?
read MON

clear
echo "rR gG bB to move gamma"
echo "lL to adjust brightness"
echo "s to save, q to reset and quit."
while read -n1 -s; do
	if [ $REPLY = 'R' ]; then
		let RR="$RR+50"
		NR=$(echo "$RR/1000"|bc -l)
		echo "RED increased"
	elif [ $REPLY = 'r' ]; then
		let RR="$RR-50"
		NR=$(echo "$RR/1000"|bc -l)
		echo "RED decreased"
	elif [ $REPLY = 'G' ]; then
		let GG="$GG+50"
		NG=$(echo "$GG/1000"|bc -l)
		echo "GREEN increased"
	elif [ $REPLY = 'g' ]; then
		let GG="$GG-50"
		NG=$(echo "$GG/1000"|bc -l)
		echo "GREEN decreased"
	elif [ $REPLY = 'B' ]; then
		let BB="$BB+50"
		NB=$(echo "$BB/1000"|bc -l)
		echo "BLUE increased"
	elif [ $REPLY = 'b' ]; then
		let BB="$BB-50"
		NB=$(echo "$BB/1000"|bc -l)
		echo "BLUE decreased"
	elif [ $REPLY = 'L' ]; then
		let LL="$LL+50"
		NL=$(echo "$LL/1000"|bc -l)
		echo "BRIGHTNESS increased"
	elif [ $REPLY = 'l' ]; then
		let LL="$LL-50"
		NL=$(echo "$LL/1000"|bc)
		echo "BRIGHTNESS decreased"
	elif [ $REPLY = s ]; then
		echo "xrandr --output $MON --gamma $NR:$NG:$NB --brightness $NL" > ~/xrandrconf
		chmod a+x ~/xrandrconf
		echo "Saved as ~/xrandrconf"
		exit 0
	elif [ $REPLY = q ]; then
		xrandr --output $MON --gamma 1.0:1.0:1.0 --brightness 1.0
		exit 0
	fi
xrandr --output $MON --gamma $NR:$NG:$NB --brightness $NL > /dev/null 2>&1
done

