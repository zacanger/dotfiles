#!/bin/bash

lang=$2
if [[ $lang == "" ]] ; then
    lang=en
fi

mplayer -prefer-ipv4 \
    "http://translate.google.com/translate_tts?ie=UTF-8&tl=$lang&q=$1";
