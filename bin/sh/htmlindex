#!/bin/sh

# will index a directory; just run it, it makes a list of
# all contents in the dir and throws the links in an index.html

echo "<html>" > ./index.html

for name in * ; do
    case "$name" in
        *.html)
            continue
            ;;
    esac
my_name=$(ls|grep $name) ;\
    echo "<a href=\""$name"\">" $my_name "</a> <br>" >> ./index.html; \
    done;

echo "<br><br>HIYA" >> ./index.html
echo "<br>HURR'S A SCRAPT" >> ./index.html
echo "<br><br>  change the ls -something command into whatever to customize." >> ./index.html

echo "<P> " >>index.html

echo "<br><a href=http://link.url><img src=pitcha.img border=0 ></a><br>" >> ./index.html
echo "</html>" >> ./index.html

