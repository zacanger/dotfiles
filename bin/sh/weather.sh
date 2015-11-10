#!/bin/sh
SEDSTR='
        # grab the three lines we are interested in
        127,130!d;

        # add parens around the first line
        s/\([^\n]*\)/(\1)/;

        # join the first two lines
        N;
        N;

        # add two slashes at the end
        s/\(.*\)/\1 \/\//;

        # join the last line
        N;

        # remove all html
        s/<[^>]*>//g;

        # remove any newlines
        s/\n/ /g;

        # replace html escape with actual char
        s/&deg;/°/;'

[ -z $1 ] && zip=21401 || zip=$1
curl "http://thefuckingweather.com/?zipcode=$zip" -s  | sed "$SEDSTR"
