#!/bin/bash

wget -q "http://imgur.com/gallery" -O -|grep 'post"'|cut -d\" -f2|while read id
do 
    echo "Downloading $id.jpg"
    wget -q -c "http://i.imgur.com/$id.jpg"
done
