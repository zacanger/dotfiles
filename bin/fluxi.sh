#!/bin/sh

adjust_output() {
	for out in $(xrandr | sed -n 's/^\([^ ]*\).*\<connected\>.*/\1/p'); do
		xrandr --output $out --gamma $1 --brightness $2
	done
}

case $1 in
	off) adjust_output 1:1:1   1.0 ;;
	*)   adjust_output 1:1:0.5 0.7 ;;
esac

