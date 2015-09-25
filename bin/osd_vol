#!/bin/bash
case $1 in
+)
       amixer set PCM 2dB+
       ;;
-)
       amixer set PCM 2dB-
       ;;
t)
       amixer set Master toggle -q
       ;;
*)
       exit 
       ;;
esac
VOLUME=`amixer get PCM | sed -ne '/Front Left/s/.*\[\(.*\)%\].*/\1/p'`
osd_cat --colour=Green --shadow 1 \
--pos bottom --align center --offset 80 --delay=1 -b percentage -P $VOLUME -T Volume
