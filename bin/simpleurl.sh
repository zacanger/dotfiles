#!/bin/bash

basehost="$1"
tag="$2"
wget="wget -q"
apikey=$(cat /home/z/bin/sh/api.key)
offset=0

while :
do
	apiurl=$($wget -O - "http://api.tumblr.com/v2/blog/$basehost/posts?api_key=$apikey&offset=$offset&tag=$tag")
	grep -q ',"posts":\[{' <<<"$apiurl" || break
	/home/z/bin/sh/json.sh <<<"$apiurl" | 
	grep -e '"original_size","url"]' -e ',"body"]' | 
	sed 's.\\..g' | 
	grep -Eo 'http://[^" ]+(gif|jpeg|jpg|png)' |
	sort -u >> "$basehost.txt"; 
	offset=$((offset+20))
	clear 
	echo "[+] Writing URL's to $basehost.txt"
done
