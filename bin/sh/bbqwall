#!/bin/bash
RESTART="`readlink -f "$0"`"
TESTSERVER="linuxbbq.org"
SERVER="http://linuxbbq.org/wallpapers/"
BBQLIST="http://linuxbbq.org/wallpapers/wallpaperlist.txt"
TERMSET="x-terminal-emulator -e "
## gui information ##
TITLE="--always-print-result --dialog-sep --image=/usr/share/icons/bbqtux2.png --title="
TITLETEXT="LinuxBBQ Wallpaper Downloader"
VER="1.0"
TEXT="Please select a wallpaper to download"

## test download server ##
   PINGTEST=`ping -c 1 "$TESTSERVER" 2>&1 | grep unknown `
   if [[ ! "$PINGTEST" = "" ]]; then 
      yad $TITLE"$TITLETEXT" --no-buttons --timeout=10 --text=" Either your Internet connection is not working or the server is down. Sorry." &
      exit 1
   fi

 if [[ ! -f "/tmp/wallpaperlist.txt" ]]; then
    cd /tmp
    wget -c "$BBQLIST"
 fi


GUI=$( cat "/tmp/wallpaperlist.txt" |# rev | cut -d '.' -f2- |rev |
yad --list $TITLE"$TITLETEXT" --column="$TEXT" --geometry="620x420" --button="gtk-quit:1" --button="gtk-ok:0")
  result=$?
  [[ $result = 1 ]] && echo "Exiting" && exit

  case $result in

1)
   echo "cancel pressed exiting"
   exit  
;;

0)
## download selection gui result ##
   GETBBQ=` echo $GUI | cut -d '|' -f 1 `
     echo "Downloading..."
   yad $TITLE"$TITLETEXT" --no-buttons --text=" Please wait, attempting $GETBBQ download ....... " &
   YPID=$!

   
   DOWNBBQ="$SERVER$GETBBQ"
    cd /home/$USER/Images && wget -c $DOWNBBQ #"$DOWNMD5"
    kill $YPID &&  yad $TITLE"$TITLETEXT" --no-buttons --timeout=2 --text=" $GETBBQ has been downloaded to $HOME/Images directory!" &
#uncomment in LXDE distros
#	pcmanfm --wallpaper-mode=stretch -w /home/$USER/Images/$GETBBQ
   sleep 2s && $RESTART && exit
;;   
esac
