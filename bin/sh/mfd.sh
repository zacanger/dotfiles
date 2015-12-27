#! /bin/bash
#echo Mediafire Download Script using Plowdown + Axel
#echo Usage mfd URL [num]
url=$1
if [ ${url:0:4} != http ]; then
   url="http://$url"
fi
#echo ${url:0:4}
echo Downloading $url
plowdown -p mtvz --run-download="axel -n 20 -a %url" $url
#Plowdown using axel and 10 threads to download the url

