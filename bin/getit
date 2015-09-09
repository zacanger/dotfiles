#!/bin/bash
if [ $# -gt 0 ]; then
  cd $1
fi

while [ 0 ]; do

  read page
  tmp=tube-get.tmp
  curl -s "$page" > $tmp
  video=`cat $tmp | grep -oP '(http[:\s\/\w\.]*(flv|mp4))[\"]' | head -1`
  if [ -z "$video" ]; then
    url=`cat $tmp | grep -oP '([:\/\w\.]*playerConfig.php[^"]*)' | uniq`

    if [ ! -z "$url" ]; then
      echo $url
      video=`curl -s "$url" | grep defaultVideo | sed s/defaultVideo:// | sed -E s/'\;.*'// | tr '\t' ' ' | sed -E 's/\s+//'`
    else
      video=`cat $tmp | grep -oP '(?<=file=)(http[:\s\/\w\.]*(flv|mp4))' | head -1`
      if [ -z "$video" ]; then
        video=`cat $tmp | grep -oP '(http[:\s\/\w\.]*(flv|mp4))' | head -1`
      fi
    fi
  fi
  unlink $tmp

wget \
  --no-use-server-timestamps \
  --header="Referer: $page" \
  --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:30.0) Gecko/20100101 Firefox/30.0"\
  "$video" &
echo "$video" >> tube-get.sources-list.txt

done 