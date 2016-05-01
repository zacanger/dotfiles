#!/usr/bin/env bash

DIR=$(pwd)

OUTPUT=$DIR/index.html

HTML="<!DOCTYPE html><html lang=\"en\"><head><title>gifland</title><meta charset=\"utf-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta
name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><meta name=\"description\" content=\"random images\"><meta name=\"author\"
content=\"zacanger\"><style type=\"text/css\">body {background:#101010;color:#dedefc;padding:.2em;font-size:1.2em;font-family:Monaco, Consolas, \"Lucida Console\",
monospace}h1,h2,h3,h4,h5,h6{margin:.2em;color:#eee;padding-bottom:.em;border-bottom:.em solid #000}ul {list-style-type:none;padding:0;margin:0}li
{display:block;margin:0;padding:.2em}li:hover {background:#272822}a {color:#6A8C8C;text-decoration:none;margin-right:1em;font-size:1.2em}a:hover {color:#93BBBB}
@media only screen and (min-width:641px) {body{font-size:1em}a {font-size:1.2rem}}</style></head><body><h3>zacanger.com/gifland</h3><h5>get the script <a
href=\"./make.sh\">here</a></h5><ul>"

for FILE in "$DIR"/*
do
	EXT=$(awk -F'.' '{print $NF}' <<< $FILE)
	if [ $EXT = "gif"  ] || [ $EXT = "jpg"  ] || [ $EXT = "jpeg"  ] || [ $EXT = "png"  ] ; then
		NAME=$(awk -F'/' '{print $NF}' <<< $FILE)
		SIZE=$(cat $FILE | wc -c)

		for DESIG in bytes kb mb gb tb pb
		do
		   [ $SIZE -lt 1024 ] && break
		   let SIZE=$SIZE/1024
		done
		HTML+="<li><a href=\"$NAME\">$NAME</a>{$SIZE $DESIG}</li>"
	fi
done

HTML+="</ul></body></html>"

echo $HTML > $OUTPUT

