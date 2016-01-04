#!/bin/bash

basehost="$1"
tag="$2"
wget="wget -nv"
apikey=$(cat /home/z/bin/sh/api.key)
offset=0
mkdir -p -- "$basehost"

while :
do
    apiurl=$($wget -O - "http://api.tumblr.com/v2/blog/$basehost/posts/video?api_key=$apikey&offset=$offset&tag=$tag")
    grep -q ',"posts":\[{' <<<"$apiurl" || break

    /home/z/bin/sh/json.sh <<<"$apiurl" | 
    grep -e '"video_url"]' | 
    sed 's.\\..g' | 
    grep -Eo 'http://[^" ]+(mp4|flv)' |
    sort -u |
    $wget -P "$basehost" -c -i - 
    offset=$((offset+20))
done
