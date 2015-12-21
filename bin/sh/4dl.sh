#!/bin/bash
## *chan Leecher ("4dl.sh") - By Harry Strongburg, first version written by Benjamin Land.
## Will download all images off a certain defined board on most *chan style boards.


serverhtml="boards.4chan.org" 	## Server you're leeching.
serverimages="images.4chan.org"	## Server hosting images.
board="g" 	## Board to download off of. Just the letter(s), no dashes.


echo "Welcome; collecting all thread info now."

## Begin collecting all threads and image URLs
wget -U "Mozilla/5.0 (X11; U; Linux i686; nl; rv:1.7.3) Gecko/20040916" -e robots=off -q -O- http://$serverhtml/$board/ | egrep "<input type=checkbox name=\"[0-9]*\" value=delete>.*filetitle" | sed "s^.*\"\([0-9]*\)\".*^http://$serverhtml/$board/res/\1^" >> threads$board

for ((i=1; i<=10; i++)) do
    wget -U "Mozilla/5.0 (X11; U; Linux i686; nl; rv:1.7.3) Gecko/20040916" -e robots=off -q -O- http://$serverhtml/$board/$i | egrep "<input type=checkbox name=\"[0-9]*\" value=delete>.*filetitle" | sed "s^.*\"\([0-9]*\)\".*^http://$serverhtml/$board/res/\1^" >> threads$board
## End collecting all threads and image URLs
    echo "Page $i thread URLs loaded."
done

echo "Collecting image URLs."

wget -U "Mozilla/5.0 (X11; U; Linux i686; nl; rv:1.7.3) Gecko/20040916" -e robots=off -q -O- -i threads$board | egrep "<a href=\"http://$serverimages/$board/src/[0-9]+.jpg\" target=\"_blank\">" | sed "s^.*\(http\://$serverimages/$board/src/[0-9]*.jpg\).*^\1^" >> images$board ## Parsing the image URLs to be downloaded


echo "Downloading all images now!"
## Falling into the loop of wgetting all images.
wget -U "Mozilla/5.0 (X11; U; Linux i686; nl; rv:1.7.3) Gecko/20040916" -e robots=off -np -c -x -q -i images$board ## Remove -q if you want verbose information.

echo "Done downloading all images; have fun!"

rm threads$board ## Erasing the temp thread data
rm images$board ## Erasing the temp image urls
