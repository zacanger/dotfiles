#!/usr/bin/env bash

# will index a directory; just run it, it makes a list of
# all contents in the dir and throws the links in an index.html

echo "<!doctype html>" >> index.html
echo "<html lang=\"en\">" >> index.html
echo "<body>" >> index.html

for name in * ; do
  case "$name" in
    *.html)
    continue
    ;;
  esac
  my_name=$(ls|grep $name) ;\
  echo "<br><a href=\""$name"\">"$my_name"</a>" >> index.html; \
done;

echo "<br>change the ls -something command into whatever to customize." >> ./index.html

echo "<p>" >> index.html
echo "</body>" >> index.html

echo "</html>" >> index.html

