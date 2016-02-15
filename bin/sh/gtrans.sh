#!/bin/bash
#Created By Kris Occhipinti
#April 13th 2011
#Released under the GPLv3
#http://FilmsByKris.com
#http://filmsbykris.com/wordpress/?p=469

lng="es"

rec -r 16000 -t alsa default /tmp/recording.flac silence 1 0.1 5% 5 1.0 5%

x=$(wget -q -U "Mozilla/5.0" --post-file /tmp/recording.flac --header="Content-Type: audio/x-flac; rate=16000" -O - "http://www.google.com/speech-api/v1/recognize?lang=en-us&client=chromium"|cut -d\" -f12)

clear
echo "$x"

y=$(wget -U "Mozilla/5.0" -qO - "http://translate.google.com/translate_a/t?client=t&text=$x&sl=auto&tl=$lng" | sed 's/\[\[\[\"//' | cut -d \" -f 1)

echo "$y"

mplayer -user-agent Mozilla "http://translate.google.com/translate_tts?tl=$lng&q=$(echo "$y" | sed 's#\ #\+#g')" > /dev/null 2>&1 ;
