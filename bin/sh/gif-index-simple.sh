#!/usr/bin/env bash

echo "<!doctype html><html lang=\"en\"><body><h1><a href=\"/\">home</a></h1>" > index.html
ls -1 | grep .gif$ | awk '{ printf "<a href=\"%s\"><img src=\"%s\"></a>\n",$1,$1,$1 }' >> index.html
echo "</body></html>" >> index.html

