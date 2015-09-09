#!/bin/bash
# -*- coding: utf-8 -*-

HEADERS=$(echo '
HTTP/1.1 200 OK                                              \n
Content-Type: text/html                                      \n
cache-control: max-age=3600                                  \n
Connection: close\n\n')

if ! test -z "$1"; then PORT=$1 ; else PORT=8080 ; fi

FIFO_FILE=/tmp/abache
test -p $FIFO_FILE && rm $FIFO_FILE
mkfifo $FIFO_FILE

while true; do
    cat "$FIFO_FILE" | nc -l --port=$PORT | while read line; do
        if echo "$line" | grep -q 'GET '; then
        	echo $(date) $line
            FILENAME=$(echo "$line" | awk '{print $2}'| sed 's/%20/ /')
            FILENAME=${FILENAME:1}
            if test -z "$FILENAME"; then
            	FILENAME="."
            fi
            CONTENT="Error"
            if test -e "$FILENAME" ; then
                if test -f "$FILENAME" ; then
                    CONTENT=$(cat "$FILENAME" < /dev/null)
                else
                    CONTENT='<html>\n<head>\n<body>\n<table>\n'
                    CONTENT="$CONTENT"'<tr>\n<td>Name</td><td>Permissions</td><td>UserId</td><td>GroupId</td><td>Size (bytes)</td></tr>\n'
                    CONTENT="$CONTENT"'<tr>\n<td><a href="..">..</a></td><td></td><td></td><td></td><td></td></tr>\n'
                    CONTENT="$CONTENT"$(stat -f '<tr>\n<td><a href="/%N">%N<a/></td><td>%p</td><td>%u</td><td>%g</td><td>%z</td></tr>\n' $FILENAME/*)
                    CONTENT="$CONTENT"'</tr>\n</table>\n</body>\n</head>\n</html>\n'
                fi
            fi
            echo -e $HEADERS "$CONTENT" > $FIFO_FILE
        fi
    done
done