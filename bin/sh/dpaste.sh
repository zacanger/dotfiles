#!/bin/sh

curl -sSi -F 'hold=on' -F 'content=<-' 'http://dpaste.com/api/v1/' \
	| awk '$1=="Location:"{print $2}'

