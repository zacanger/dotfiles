#!/usr/bin/env bash

function mp3(){
  cd ~/Downloads
  echo "youtube link, please?"
  read link
  sleep 1
  youtube-dl $link -t -x --audio-format "mp3"
  exit 0
}

function ytuser(){
  cd ~/Downloads
  echo "youtube username, please?"
  read username
  youtube-dl -citw ytuser:$username
  exit 0
}

function singleVid(){
  cd ~/Downloads
  echo "youtube link, please?"
  read link
  youtube-dl $link --max-quality "mp4" -t
  exit 0
}


while : #loop
do
cat << !
R U N M E N U

1. Download mp3
2. Download entire youtube-user
3. Download a single Youtube Video in mp4-format
4. quit
!

echo -n " Your choice? : "
read choice

case $choice in
1) mp3 ;;
2) ytuser ;;
3) singleVid ;;
4) exit ;;
*) echo "\"$choice\" is not valid"; sleep 2;;
esac
done

