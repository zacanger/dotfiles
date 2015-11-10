#!/bin/sh
shopt -s globstar
mkdir tmp
pushd tmp &>/dev/null
wget -rNA html 'http://www.radcap.ru/'

find . -type f -iname '*.html' -exec grep -o 'play\/[^>]*m3u' {} \; |\
    while read line; do
        echo "http://radcap.ru/$line";
    done

popd &>/dev/null
rm -rf ./tmp
