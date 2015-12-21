#!/bin/bash
# Please do not use this script to spam. #
# Also this script is depreciated #

banner="
                               __       
                         _ __ / _|_ __  
                        | '__| |_| '_ \ 
                        | |  |  _| |_) |
                        |_|  |_| | .__/ 
                                 |_|    
                        -v9.1 (Mar/18/10)

"

#rfp.sh, the automated poster. You may use this file for any and all purposes.
#Nobody can be held responsible for your use of this file.
#Please do not use this to spam (though I know you probably care what I request)
#If you disagree with this text, then good day to you sir.

#Description: simple script to automate tasks on 4chan.
#Depends on; curl, bash
#Usage; chmod +x rfp.sh; edit vars, then ./rfp.sh it
#Direct bugreports, suggestions, donations, hate-mail, etc to rfpREMOVETHIS@harry.lu


#changelog; 
# Mar 18 10 - Fixed success-post message (coppied the awk from blargh on #/g/tv's script, thanks), overall cleaned up code.
# Jan 13 10 - "imageboard.php" -> "post"
# Jan 05 10 - Fixed new-threads, added cross-posting.
# Dec 22 09 - Updated for 4chan's "boards." subdomain. Removed some useless unused features, and removed a few unused *chans I was too lazy to update/use.
# Aug/26/09 - Added new mode "sage" for posting text only (useful for sagebombing), "fixed" the bug that autobanned you.

#####
## vars - change me
#####
useragent="Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.1.8) Gecko/20100214 Firefox/3.5.8" #Find your useragent @ http://whatsmyuseragent.com/ and insert it here. Not needed, but will keep down on bans.
PWD=$RANDOM #$RANDOM for random numbers as password.
SLEEP=46 #secs to wait until next post attempt
COMMENT="4chan is fun! " #multiline comments supported. $RANDOM for random numbers.



#####
## no real need to change this
#####
NUM=1
BUMP=1
UNIQUE=""
timeout=60 ## Increase if your connection is slow / are uploading large files.
reed="read -e"

CURL=`which curl` ## Thanks for the idea, rj.sh
if [ -z "$CURL" ]; then
	echo "This script depends on cURL, make sure it's installed and in your path."
	exit 1
fi

clear;echo "$banner"
#####
## this shit below is the default configs
## may change, mods may create wordfilters to ban your scripting ass forever.
## stay vigilant, don't spam useless crap
#####


fourchan(){
clear; echo "$banner"
     echo  "                           ________________________

                                  4chan menu
                           ________________________
"
echo "Choose a board > "
echo -n " (a,b,c,d,e,f,g,gif,h,hr,k,m,o,p,r,s,t,u,v,w,
  wg,i,ic,cm,y,an,cgl,ck,co,mu,n,po,tg,tv,x,test): " ; $reed iboard ; echo "";
case "$iboard" in
   b)
        iserver="images"
        pserver="sys"
        post="post"
        ;;
   a|c|g|k|m|o|p|v|w|cm|an|ck|co|mu|po|tg|tv|x)
        iserver="images"
        pserver="sys"
        post="post"
        ;;
   d|e|hr|u|wg|y|cgl|n)
        iserver="images"
        pserver="sys"
        post="post"
        ;;
   gif|h|r|s|t|i|ic)
        iserver="images"
        pserver="sys"
        post="post"
        ;;
  test)
	iserver="test"
	pserver="test"
	post=""
	;;
   *)
        fourchan
        ;;
esac
##################
BOARD="http://$pserver.4chan.org/$iboard/$post"
##################
echo -n "Postmode>
 (file/dump/sage/crosspost): "; $reed rfp; echo ""
case "$rfp" in

file|fil|fi|f)
        echo "Select file to post with>"; echo -n " (eg. /home/user/pic.jpg): "; $reed IMAGE
         if [ ! -e "$IMAGE" ]
           then
           echo ""; echo -n " "; echo -n "$IMAGE does not exist..."; sleep 1; fourchan
         fi
        echo ""; echo " image: $(ls -sh $IMAGE) selected..." ; echo ""
        echo "Name>"; echo -n " (leave blank for none): "; $reed NAME; echo ""
        echo "Email>"; echo -n " (leave blank for none): "; $reed EMAIL; echo ""
        echo "Subject>"; echo -n " (leave blank for none): "; $reed SUB; echo ""
	echo "Comment>"; echo -n " (leave blank for random): "; $reed COMMENT; echo ""        
	echo "URL of thread(s)>"; echo -n " (eg. 1993711, or 0 for new threads): "; $reed URL; echo ""

        while true 
        do
        for url in $URL
        do
        echo $RANDOM >> $IMAGE ## Anti-dupe image.
        echo [$NUM] [$IMAGE - $PWD] ; echo ""  ; echo -n " >> "
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM"  -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" $BOARD | awk '/Post successful!/ {print "POST SUCCESSFUL!"} /Error: Duplicate file entry detected./ {print "Duplicate."} /Error: Flood detected./ {print "Flood detected."} /Max limit of/ {print "Max limit reached."} /Abnormal reply/ {print "Abnormal reply."} /Error: No file selected./ {print "No file selected."} /Error: Cannot find record./ {print "Cannot find record."} /Error: No text entered./ {print "No text entered."} /404 - Not Found/ {print "404 - Not found."} /Thread specified does/ {print "Thread does not exist."} /You are banned ;_;/ {print "Banned."} /Error: Field too long./ {print "Field too long."} /Error: File too large./ {print "File too large."} /Detected possible malicious code in image file./ {print "Detected possible malicious code in image file."} /Error: Image resolution is too large./ {print "Image resolution too large."} /Updating index.../ {print "Updating index..."} /Error: Upload failed./ {print "Upload failed."} /Error: Invalid tag specified./ {print "Invalid tag."} /Image file contains embedded archive./ {print "Image contains embedded archive."} /This board doesn/ {print "This board does not exist."} /You are trying to use a node of the CoDeeN CDN Network/ {print "Shit Proxy."} '
        let "NUM += 1"
        echo ""; echo " * Waiting $SLEEP seconds..."; echo ""
        sleep $SLEEP
        done
        done
        echo " Done."
        ;;

dump|dum|du|d)
        echo "Select dir(s) to dump>"; echo -n " (eg. /home/user/pics/* /home/user/gay/*): "; $reed FILES ; echo ""
	echo "$(ls -shd $FILES)"; echo ""
        echo "Name>"; echo -n " (leave blank for none): "; $reed NAME; echo ""
        echo "Email>"; echo -n " (leave blank for none): "; $reed EMAIL; echo ""
        echo "Subject>"; echo -n " (leave blank for none): "; $reed SUB; echo ""
	echo "Comment>"; echo -n " (leave blank for random): "; $reed COMMENT; echo ""  
        echo "URL of thread>"; echo -n " (eg. 1993711, or 0 for new threads): "; $reed URL ;echo ""
        for file in $FILES
        do
         if [ ! -e "$file" ]
          then
          echo ""; echo " * $file does not exist."
          continue
         fi
         if [ -d "$file" ]
          then
          echo ""; echo " * $file is a folder."
          continue
         fi
        echo ""; echo "[$NUM] [" $(ls -sphd "$file") $(echo "$URL - $BOARD]")  ; echo ""  ; echo -n " >> "
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$URL" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$file" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" $BOARD | awk '/Post successful!/ {print "POST SUCCESSFUL!"} /Error: Duplicate file entry detected./ {print "Duplicate."} /Error: Flood detected./ {print "Flood detected."} /Max limit of/ {print "Max limit reached."} /Abnormal reply/ {print "Abnormal reply."} /Error: No file selected./ {print "No file selected."} /Error: Cannot find record./ {print "Cannot find record."} /Error: No text entered./ {print "No text entered."} /404 - Not Found/ {print "404 - Not found."} /Thread specified does/ {print "Thread does not exist."} /You are banned ;_;/ {print "Banned."} /Error: Field too long./ {print "Field too long."} /Error: File too large./ {print "File too large."} /Detected possible malicious code in image file./ {print "Detected possible malicious code in image file."} /Error: Image resolution is too large./ {print "Image resolution too large."} /Updating index.../ {print "Updating index..."} /Error: Upload failed./ {print "Upload failed."} /Error: Invalid tag specified./ {print "Invalid tag."} /Image file contains embedded archive./ {print "Image contains embedded archive."} /This board doesn/ {print "This board does not exist."} /You are trying to use a node of the CoDeeN CDN Network/ {print "Shit Proxy."} '
        let "NUM += 1"
        echo ""; echo " * Waiting $SLEEP seconds..."
        sleep $SLEEP
        continue
        done
        ;;

sage|s|h)
        echo "Name>"; echo -n " (leave blank for none): "; $reed NAME; echo ""
        echo "Email>"; echo -n " (leave blank for none): "; $reed EMAIL; echo ""
        echo "Subject>"; echo -n " (leave blank for none): "; $reed SUB; echo ""
	echo "Comment>"; echo -n " (leave blank for random): "; $reed COMMENT; echo ""  
        echo "URL of thread(s)>"; echo -n " (eg. 1993711, or 0 for new threads): "; $reed URL ;echo ""

        while true 
        do
        for url in $URL
        do
        echo [$NUM] [$PWD] ; echo ""  ; echo -n " >> "
        c\url -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" $BOARD | awk '/Post successful!/ {print "POST SUCCESSFUL!"} /Error: Duplicate file entry detected./ {print "Duplicate."} /Error: Flood detected./ {print "Flood detected."} /Max limit of/ {print "Max limit reached."} /Abnormal reply/ {print "Abnormal reply."} /Error: No file selected./ {print "No file selected."} /Error: Cannot find record./ {print "Cannot find record."} /Error: No text entered./ {print "No text entered."} /404 - Not Found/ {print "404 - Not found."} /Thread specified does/ {print "Thread does not exist."} /You are banned ;_;/ {print "Banned."} /Error: Field too long./ {print "Field too long."} /Error: File too large./ {print "File too large."} /Detected possible malicious code in image file./ {print "Detected possible malicious code in image file."} /Error: Image resolution is too large./ {print "Image resolution too large."} /Updating index.../ {print "Updating index..."} /Error: Upload failed./ {print "Upload failed."} /Error: Invalid tag specified./ {print "Invalid tag."} /Image file contains embedded archive./ {print "Image contains embedded archive."} /This board doesn/ {print "This board does not exist."} /You are trying to use a node of the CoDeeN CDN Network/ {print "Shit Proxy."} '
        let "NUM += 1"
        echo ""; echo " * Waiting $SLEEP seconds..."; echo ""
        #let $SLEEP2 = $SLEEP + $RANDOM % 5  #im not a script, srsly u guise lolol
        sleep $SLEEP
        done
        done
        echo " Done."
        ;;

c|crosspost|cross)
echo "Select file to post with>"; echo -n " (eg. /home/user/pic.jpg): "; $reed IMAGE
         if [ ! -e "$IMAGE" ]
           then
           echo ""; echo -n " "; echo -n "$IMAGE does not exist..."; sleep 1; fourchan
         fi
        echo ""; echo " image: $(ls -sh $IMAGE) selected..." ; echo ""
        echo "Name>"; echo -n " (leave blank for none): "; $reed NAME; echo ""
        echo "Email>"; echo -n " (leave blank for none): "; $reed EMAIL; echo ""
        echo "Subject>"; echo -n " (leave blank for none): "; $reed SUB; echo ""
	echo "Comment>"; echo -n " (leave blank for random): "; $reed COMMENT; echo ""          
	echo "URL of thread(s)>"; echo -n " (eg. 1993711, or 0 for new threads): "; $reed URL ;echo ""

        while true 
        do
        for url in $URL
        do
        echo $COMMENT >> $IMAGE
        echo [$NUM] [$IMAGE - $PWD] ; echo ""  ; echo -n " >> "

	## I'll shorten this eventually, I just can't be bothered to at the moment.
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/a/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/b/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/c/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/d/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/e/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/g/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/gif/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/h/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/hr/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/k/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/m/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/o/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/p/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/r/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/s/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/t/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/u/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/v/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/w/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/wg/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/ic/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/cm/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/y/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/r9k/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/an/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/cgl/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/ck/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/co/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/fa/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/fit/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/jp/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/mu/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/n/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/po/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/sp/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/tg/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/toy/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/trv/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/tv/imgboard.php
        curl -s -S -A "$useragent" --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT$RANDOM" -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" http://sys.4chan.org/x/imgboard.php



        let "NUM += 1"
        echo ""; echo " * Waiting $SLEEP seconds..."; echo ""
        #let $SLEEP2 = $SLEEP + $RANDOM % 5  #im not a script, srsly u guise lolol
        sleep $SLEEP
        done
        done
        echo " Done."
        ;;



*)
        fourchan
        ;;
esac
}
#################################################
################ end of 4chan() #################
#################################################

# No longer needed, no longer posting on multiple chans.
# Kept for the learning, and old time sake.
#echo "Select a chan > "
#echo -n " (4chan): "; $reed CHAN
#case "$CHAN" in
#     4chan|4ch|4)
#           CHAN=4chan
#           fourchan
#          ;;
#     *)
#	   echo "What?"
#           ;;
#esac


fourchan;

echo ""; echo "Done."
