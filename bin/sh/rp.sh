#!/bin/bash
banner="
                                                  _
                                                 | |
                        _ __ __ _ _ __  ___   ___| |_
                       | '_ / _� | '_ \/ _ \ / __| , \`. 
                       | | | (_| | |_)   __/_\__ \ || | 
                       |_|  \__,_| ,__/\___(_)___/_||_| 
                                 |_| 
                                      -v 5 (13/8/07)

"

#rape the spamscript, you may use this file for any and all purposes
#nobody can be held responsible for your use of this file 
#if you disagree with this text then good day to you sir

#description: shitty script to automate tasks on gay little wapanese boards

#depends on; curl, bash

#usage; chmod +x rape.sh; edit vars then ./run it

#direct bugreports, spam, etc to win32blows@gmail.com
#http://freewebs.com/fukkensaved/  lol freewebs

#changelog; 
# 11/8/07 - hello world
# 11/8/07 - added random thread reply
# 12/8/07 - bugfixes
# 12/8/07 - field too long message added
# 12/8/07 - bugfixes
# 13/8/07 (trellis' mod)
#	  - read -e
#         - imgcount fix
#         - now spamming multiple arbitrary threads
# 13/8/07 - added 420chan and wtfux

#####
## vars - change me
#####
useragent="Mozilla/5.0"
PWD=changeme #$RANDOM for random
SLEEP=10  #secs to wait until next post attempt
COMMENT="

"       #multiline comments supported

#####
## no real need to change this
#####
NUM=1
BUMP=1
UNIQUE=""
timeout=15
reed="read -e"

clear;echo "$banner"
#####
## this shit below is the default configs for the most popular chans
## shit may change, kikemods may create wordfilters to ban your scripting ass forever, so stay vigilant
#####

#################################################
###############4chan works Thu 9/8/07############
#################################################
fourchan(){
clear; echo "$banner"
     echo  "                           ________________________

                                  4chan menu
                           ________________________
"
echo "Choose a board > "
echo -n " (a,b,c,d,e,f,g,gif,h,hr,k,m,o,p,r,s,t,u,v,w,
  wg,i,ic,cm,y,an,cgl,ck,co,mu,n,po,tg,tv,x): " ; $reed iboard ; echo "";
case "$iboard" in
   b)
        iserver="img"
        pserver="dat"
        post="imgboard.php"
        ;;
   a|c|g|k|m|o|p|v|w|cm|an|ck|co|mu|po|tg|tv|x)
        iserver="zip"
        pserver="bin"
        post="imgboard.php"
        ;;
   d|e|hr|u|wg|y|cgl|n)
        iserver="orz"
        pserver="tmp"
        post="imgboard.php"
        ;;
   f)
        iserver="cgi"
        pserver="nov"
        post="up.php"
        ;;
   gif|h|r|s|t|i|ic)
        iserver="cgi"
        pserver="nov"
        post="imgboard.php"
        ;;
   *)
        fourchan
        ;;
esac
##################
BOARD="http://$pserver.4chan.org/$iboard/$post"
##################
echo -n "Rapemode>
 (file/dump/random/count): "; $reed rape; echo ""
case "$rape" in
file|fil|fi|f)
        echo "Select file to spam with>"; echo -n " (eg. /home/user/pic.jpg): "; $reed IMAGE
         if [ ! -e "$IMAGE" ]
           then
           echo ""; echo -n " "; echo -n "$IMAGE does not exist..."; sleep 1; fourchan
         fi
        echo ""; echo " image: $(ls -sh $IMAGE) selected...&#776;&#769;" ; echo ""
        echo "Name>"; echo -n " (leave blank for none): "; $reed NAME; echo ""
        echo "Email>"; echo -n " (leave blank for none): "; $reed EMAIL; echo ""
        echo "Subject>"; echo -n " (leave blank for none): "; $reed SUB; echo ""
        echo "URL of thread(s)>"; echo -n " (eg. 1993711 1993711 or blank for new threads): "; $reed URL ;echo ""

        while true 
        do
        for url in $URL
        do
        echo -n "." >> $IMAGE
        echo [$NUM] [$IMAGE - $PWD] ; echo ""  ; echo -n " >> "
        curl -s -S -A $useragent --max-time $timeout --max-filesize 3145728 -F "resto=$url" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT"  -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" $BOARD | awk '/Updating page./ {print "Successfully uploaded!"} /Error: Duplicate file entry detected./ {print "Duplicate."} /Error: Flood detected./ {print "Flood detected."} /Max limit of/ {print "Max limit reached."} /Abnormal reply/ {print "Oh fuck."} /Error: No file selected./ {print "No file selected."} /Error: Cannot find record./ {print "Cannot find record."} /Error: No text entered./ {print "No text entered."} /Thread specified does not exist./ {print "Thread does not exist."}  /404 - Not Found/ {print "404 - Not found."} /You are banned ;_;/ {print "Banned."} /Error: Field too long./ {print "Field too long."}'
        let "NUM += 1"
        echo ""; echo " * Waiting $SLEEP seconds..."; echo ""
        #let "SLEEP = SLEEP + $RANDOM % 5"  #im not a script, srsly u guise lolol
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
        echo "URL of thread>"; echo -n " (eg. 1993711 or blank for new threads): "; $reed URL ;echo ""
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
        curl -s -S -A $useragent --max-time $timeout --max-filesize 3145728 -F "resto=$URL" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT" -F "upfile=@$file" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" $BOARD | awk '/Updating page./ {print "Successfully uploaded!"} /Error: Duplicate file entry detected./ {print "Duplicate."} /Error: Flood detected./ {print "Flood detected."} /Max limit of/ {print "Max limit reached."} /Abnormal reply/ {print "Abnormal reply."} /Error: No file selected./ {print "No file selected."} /Error: Cannot find record./ {print "Cannot find record."} /Error: No text entered./ {print "No text entered."} /404 - Not Found/ {print "404 - Not found."} /You are banned ;_;/ {print "Banned."} /Error: Field too long./ {print "Field too long."}'
        let "NUM += 1"
        echo ""; echo " * Waiting $SLEEP seconds..."
        sleep $SLEEP
        continue
        done
        ;;
random|rando|rand|ran|ra|r)
        echo "Select file to spam random threads>"; echo -n " (eg. /home/user/pic.jpg): "; $reed IMAGE
         if [ ! -e "$IMAGE" ]
           then
           echo ""; echo -n " "; echo -n "$IMAGE does not exist..."; sleep 1; fourchan
         fi
        echo ""; echo " image: $(ls -sh $IMAGE) selected..."; echo ""
        echo "Name>"; echo -n " (leave blank for none): "; $reed NAME; echo ""
        echo "Email>"; echo -n " (leave blank for none): "; $reed EMAIL; echo ""
        echo "Subject>"; echo -n " (leave blank for none): "; $reed SUB; echo ""
        while true
        do
        URL=$(curl -s -S -A $useragent "http://$iserver.4chan.org/$iboard/imgboard.html" | grep '<span class="postername">'|(read x x x b x x x x x x x; echo $b|sed s/....$//|sed 1s/^............//) )
        echo -n "." >> $IMAGE
        echo [$NUM] [$IMAGE - $PWD - $URL]  ; echo ""  ; echo -n " >> "
        curl -s -S -A $useragent --max-time $timeout --max-filesize 3145728 -F "resto=$URL" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT"  -F "upfile=@$IMAGE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" $BOARD | awk '/Updating page./ {print "Successfully uploaded!"} /Error: Duplicate file entry detected./ {print "Duplicate."} /Error: Flood detected./ {print "Flood detected."} /Max limit of/ {print "Max limit reached."} /Abnormal reply/ {print "Oh fuck."} /Error: No file selected./ {print "No file selected."} /Error: Cannot find record./ {print "Cannot find record."} /Error: No text entered./ {print "No text entered."} /Thread specified does not exist./ {print "Thread does not exist."}  /404 - Not Found/ {print "404 - Not found."} /You are banned ;_;/ {print "Banned."} /Error: Field too long./ {print "Field too long."}'
        let "NUM += 1"
        echo ""; echo " * Waiting $SLEEP seconds..."; echo ""
        #let "SLEEP = SLEEP + $RANDOM % 5"  #im not a script, srsly u guise lolol
        sleep $SLEEP
        done
        ;;
count|coun|cou|co|c)
        echo "Select thread(s) to count images>" ; echo -n " (eg. 111941 112013 112151): " ; $reed threads; echo ""
        while true; do
        for thread in $threads; do
        echo ""; echo "                               images in $CHAN's /$iboard/ $thread"
        echo "________________________________________________________________________________________________________,"
        echo "   5|  10|  15|  20|  25|  30|  35|  40|  45|  50|  55|  60|  65|  70|  75|  80|  85|  90|  95| 100| 105|"
##################
HTML="http://$iserver.4chan.org/$iboard/res/$thread.html"
##################
        curl -s -A $useragent --max-time $timeout $HTML | awk '/File :/ {printf "|"}'
        sleep 1;
        done
        done
        ;;
*)
        fourchan
        ;;
esac
}
#################################################
################ end of 4chan() #################
#################################################



#################################################
###############7chan works Thu 9/8/07############
#########except the boards with captchas#########
#################################################
sevenchan(){
clear; echo "$banner"
     echo  "                           ________________________  
                                                     
                                  7chan menu         
                           ________________________  
"
echo "Choose a board > "
echo -n " (a,b,c,d,e,f,g,gif,h,hr,k,m,o,p,r,s,t,u,v,w,
  wg,i,ic,cm,y,an,cgl,ck,co,mu,n,po,tg,tv,x): " ; $reed iboard ; echo "";
case "$iboard" in
   cake|d|di|fn|fur|gu|men|s|sm|ss|u|y)
        iserver="fap"
        pserver="fap"
        post="board.php"
        ;;
   34|b|rx|fail|fl|gif|r|svg|t|vid|w|wp|x|zom|be|jb|pco)
        iserver="img"
        pserver="img"
        post="board.php"
        ;;
   a|ani|cat|cf|g|halp|lit|me|tech|vg)
        iserver="sfw"
        pserver="sfw"
        post="board.php"
        ;;
   co|fit|oe|pr)
        iserver="lol"
        pserver="lol"
        post="board.php"
        ;;
   *)
        sevenchan
        ;;
esac

##################
BOARD="http://$pserver.7chan.org/$post"
##################
echo -n "Rapemode>
 (file/dump/count): "; $reed rape; echo ""
case "$rape" in
file|fil|fi|f)
        echo "Select file to spam with>"; echo -n " (eg. /home/user/pic.jpg): "; $reed IMAGE
         if [ ! -e "$IMAGE" ]
           then
           echo ""; echo -n " "; echo -n "$IMAGE does not exist..."; sleep 1; sevenchan
         fi
        echo ""; echo " image: $(ls -sh $IMAGE) selected..."; echo ""
        echo "Name>"; echo -n " (leave blank for none): "; $reed NAME; echo ""
        echo "Email>"; echo -n " (leave blank for none): "; $reed EMAIL; echo ""
        echo "Subject>"; echo -n " (leave blank for none): "; $reed SUB; echo ""
        echo "URL of thread(s)>"; echo -n " (eg. 1993711 123345 or 0 for new threads): "; $reed URL ;echo ""
        while true
        do
        for url in $URL
        do
        echo -n "." >> $IMAGE
        echo [$NUM] [$IMAGE - $PWD] ; echo ""  ; echo -n " >> "
        curl -s -S -A $useragent --max-time $timeout --max-filesize 3145728 -F "board=$iboard" -F "replythread=$url" -F "name=$NAME" -F "em=$EMAIL" -F "subject=$SUB"  -F "message=$COMMENT" -F "imagefile=@$IMAGE" -F "postpassword=$PWD"  $BOARD | awk '/Updating page./ {print "Successfully uploaded!"} /Error: Duplicate file entry detected./ {print "Duplicate."} /Error: Flood detected./ {print "Flood detected."} /Max limit of/ {print "Max limit reached."} /Abnormal reply/ {print "Abnormal reply."} /Error: No file selected./ {print "No file selected."} /Error: Cannot find record./ {print "Cannot find record."} /Error: No text entered./ {print "No text entered."} /404 - Not Found/ {print "404 - Not found."} /<title>YOU ARE BANNED!/ {print "Banned."} /Error: Field too long./ {print "Field too long."}'
        let "NUM += 1"
        echo ""; echo " * Waiting $SLEEP seconds..."; echo ""
        #let "SLEEP = SLEEP + $RANDOM % 5"  #im not a script, srsly u guise lolol
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
        echo "URL of thread>"; echo -n " (eg. 1993711 or 0 for new threads): "; $reed URL ;echo ""
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
        echo ""; echo "[$NUM] [" $(ls -sphd "$file") $(echo "$URL]") ; echo ""  ; echo -n " >> "
        curl -s -S -A $useragent --max-time $timeout --max-filesize 3145728 -F "board=$iboard" -F "replythread=$URL" -F "name=$NAME" -F "em=$EMAIL" -F "subject=$SUB"  -F "message=$COMMENT" -F "imagefile=@$file" -F "postpassword=$PWD"  $BOARD | awk '/Updating page./ {print "Successfully uploaded!"} /Error: Duplicate file entry detected./ {print "Duplicate."} /Error: Flood detected./ {print "Flood detected."} /Max limit of/ {print "Max limit reached."} /Abnormal reply/ {print "Abnormal reply."} /Error: No file selected./ {print "No file selected."} /Error: Cannot find record./ {print "Cannot find record."} /Error: No text entered./ {print "No text entered."} /404 - Not Found/ {print "404 - Not found."} /<title>YOU ARE BANNED!/ {print "Banned."} /Error: Field too long./ {print "Field too long."}'
        let "NUM += 1"
        echo ""; echo " * Waiting $SLEEP seconds..."
        sleep $SLEEP
        continue
        done
        ;;
count|coun|cou|co|c)
        echo "Select thread(s) to count images>" ; echo -n " (eg. 111941 112013 112151): " ; $reed threads; echo ""
        while true; do
        for thread in $threads; do
        echo ""; echo "                               images in $CHAN's /$iboard/ $thread"
        echo "________________________________________________________________________________________________________,"
        echo "   5|  10|  15|  20|  25|  30|  35|  40|  45|  50|  55|  60|  65|  70|  75|  80|  85|  90|  95| 100| 105|"
##################
HTML="http://$iserver.7chan.org/$iboard/res/$thread.html"
##################
        curl -s -A $useragent --max-time $timeout $HTML | awk '/File :/ {printf "|"}'
        sleep 1;
        done
        done
        ;;
*)
        sevenchan
        ;;
esac
}
#################################################
################ end of 7chan() #################
#################################################


#################################################
#############420chan works Thu 13/8/07###########
#################################################
boringchan(){
clear; echo "$banner"
     echo  "                           ________________________  
                                                     
                                 420chan menu         
                           ________________________  
"
echo "Choose a board > "
echo -n " (420,b,i,mma,wooo,weed,hooch,mdma,hal,stim,dis,
 opi,smoke,benz,del,other,f,m,po,vg,cd,gif,meow,w): " ; read iboard ; echo "";
case "$iboard" in
   b|f|m|cd|gif|meow|w)
	iserver="img"
	pserver="img"
	post="wakaba.pl"
	i=0
	;;
   420|mma|wooo|weed|hooch|mdma|hal|stim|dis|opi|smoke|benz|del|other|po|vg)
	iserver="disc"
	pserver="disc"
	post="wakaba.pl"
	i=0
	;;
   i)
	post="wakaba.pl"
	i=1
	;;
   *)
	boringchan
	;;
esac

##################
if [ "$i" -eq 0 ]
then BOARD="http://$pserver.420chan.org/$iboard/wakaba.pl"
else BOARD="http://not420chan.com/$iboard/wakaba.pl"
fi
##################
echo -n "Rapemode>
 (file/dump/count): "; $reed rape; echo ""
case "$rape" in
file|fil|fi|f)
        echo "Select file to spam with>"; echo -n " (eg. /home/user/pic.jpg): "; $reed IMAGE
         if [ ! -e "$IMAGE" ]
           then
           echo ""; echo -n " "; echo -n "$IMAGE does not exist..."; sleep 1; boringchan
         fi
        echo ""; echo " image: $(ls -sh $IMAGE) selected..."; echo ""
        echo "Name>"; echo -n " (leave blank for none): "; $reed NAME; echo ""
        echo "Email>"; echo -n " (leave blank for none): "; $reed EMAIL; echo ""
        echo "Subject>"; echo -n " (leave blank for none): "; $reed SUB; echo ""
        echo "URL of thread(s)>"; echo -n " (eg. 1993711 123345 or 0 for new threads): "; $reed URL ;echo ""
        while true
        do
        for url in $URL
        do
        echo -n "." >> $IMAGE
        echo [$NUM] [$IMAGE - $PWD] ; echo ""  ; echo -n " >> "
	curl -s -S -A Mozilla/4.0 -F "task=post" -F "parent=$URL" -F "field1=$NAME" -F "field2=$EMAIL" -F "field3=$SUB" -F "field4=$COMMENT" -F "file=@$IMAGE" -F "password=$PWD" $BOARD  |  awk '/index.html/ {print "Successfully uploaded!"} /Upload something smaller/ {print "File too big."} /Either this image is too big or there is no image at all/ {print "File too big or no file selected."} /Cannot find reply/ {print "Cannot find reply."} /Upload failed/ {print "Upload failed."} /Cannot find record/ {print "Cannot find record."} /No verification code on record/ {print "No verification code on record."} /Wrong verification code entered/ {print "Wrong verification code."} /File format not supported/ {print "File format not supported."} /String refused/ {print "String refused."} /Unjust POST/ {print "Unjust POST."} /No file selected/ {print "No file selected."} /No comment entered/ {print "No comment entered,"} /Too many characters in text field/ {print "Text field too long."} /Posting not allowed/ {print "Posting not allowed."} /Abnormal reply/ {print "Abnormal reply smaller"} /Host is banned/ {print "Banned."} /Proxy is banned for being open/ {print "Proxy banned."} /Flood detected, post discarded/ {print "Flood detected, post discarded."} /Flood detected, file discarded/ {print "Flood detected, file discarded."} /Flood detected/ {print "Flood detected."} /Open proxy detected/ {print "Proxy detected."} /This file has already been posted/ {print "Duplicate file detected."} /A file with the same name already exists/ {print "Duplicated file name detected."} /Thread does not exist/ {print "Thread does not exist."} /Possible virus-infected file/ {print "Possible virus-infected file."} /Could not write to directory/ {print "Could not write to server dir."} /Spammers are not welcome here/ {print "Spammer detected."} /SQL connection failure/ {print "SQL connection failure."} /Critical SQL problem!/ {print "Critical SQL problem."}'
        let "NUM += 1"
        echo ""; echo " * Waiting $SLEEP seconds..."; echo ""
        #let "SLEEP = SLEEP + $RANDOM % 5"  #im not a script, srsly u guise lolol
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
        echo "URL of thread>"; echo -n " (eg. 1993711 or 0 for new threads): "; $reed URL ;echo ""
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
        echo ""; echo "[$NUM] [" $(ls -sphd "$file") $(echo "$URL]") ; echo ""  ; echo -n " >> "
	curl -s -S -A Mozilla/4.0 -F "task=post" -F "parent=$URL" -F "field1=$NAME" -F "field2=$EMAIL" -F "field3=$SUB" -F "field4=$COMMENT" -F "file=@$file" -F "password=$PWD" $BOARD  | awk '/index.html/ {print "Successfully uploaded!"} /Upload something smaller/ {print "File too big."} /Either this image is too big or there is no image at all/ {print "File too big or no file selected."} /Cannot find reply/ {print "Cannot find reply."} /Upload failed/ {print "Upload failed."} /Cannot find record/ {print "Cannot find record."} /No verification code on record/ {print "No verification code on record."} /Wrong verification code entered/ {print "Wrong verification code."} /File format not supported/ {print "File format not supported."} /String refused/ {print "String refused."} /Unjust POST/ {print "Unjust POST."} /No file selected/ {print "No file selected."} /No comment entered/ {print "No comment entered,"} /Too many characters in text field/ {print "Text field too long."} /Posting not allowed/ {print "Posting not allowed."} /Abnormal reply/ {print "Abnormal reply smaller"} /Host is banned/ {print "Banned."} /Proxy is banned for being open/ {print "Proxy banned."} /Flood detected, post discarded/ {print "Flood detected, post discarded."} /Flood detected, file discarded/ {print "Flood detected, file discarded."} /Flood detected/ {print "Flood detected."} /Open proxy detected/ {print "Proxy detected."} /This file has already been posted/ {print "Duplicate file detected."} /A file with the same name already exists/ {print "Duplicated file name detected."} /Thread does not exist/ {print "Thread does not exist."} /Possible virus-infected file/ {print "Possible virus-infected file."} /Could not write to directory/ {print "Could not write to server dir."} /Spammers are not welcome here/ {print "Spammer detected."} /SQL connection failure/ {print "SQL connection failure."} /Critical SQL problem!/ {print "Critical SQL problem."}'
        let "NUM += 1"
        let "NUM += 1"
        echo ""; echo " * Waiting $SLEEP seconds..."
        sleep $SLEEP
        continue
        done
        ;;
count|coun|cou|co|c)
        echo "Select thread(s) to count images>" ; echo -n " (eg. 111941 112013 112151): " ; $reed threads; echo ""
        while true; do
        for thread in $threads; do
        echo ""; echo "                               images in $CHAN's /$iboard/ $thread"
        echo "________________________________________________________________________________________________________,"
        echo "   5|  10|  15|  20|  25|  30|  35|  40|  45|  50|  55|  60|  65|  70|  75|  80|  85|  90|  95| 100| 105|"
##################
if [ "$i" -eq 0 ]
then HTML="http://$iserver.420chan.org/$iboard/res/$thread.html"
else HTML="http://not420chan.com/$iboard/res/$thread.html"
fi
##################
        curl -s -A $useragent --max-time $timeout $HTML | awk '/File :/ {printf "|"}'
        sleep 1;
        done
        done
        ;;
*)
        boringchan
        ;;
esac
}
#################################################
############### end of 420chan() ################
#################################################


#################################################
##############wtfux works Thu 13/8/07############
#################################################
wtfux(){
clear; echo "$banner"
     echo  "                           ________________________  
                                                     
                                  wtfux menu         
                           ________________________  
"
echo "Choose a board > "
echo -n " (cams,cats,random,flash,jihad,
 gaming,pron,hentai,mporn): " ; read iboard ; echo "";

##################
BOARD="http://wtfux.org/$iboard/wakaba.pl"
##################
echo -n "Rapemode>
 (file/dump/count): "; $reed rape; echo ""
case "$rape" in
file|fil|fi|f)
        echo "Select file to spam with>"; echo -n " (eg. /home/user/pic.jpg): "; $reed IMAGE
         if [ ! -e "$IMAGE" ]
           then
           echo ""; echo -n " "; echo -n "$IMAGE does not exist..."; sleep 1; wtfux
         fi
        echo ""; echo " image: $(ls -sh $IMAGE) selected..."; echo ""
        echo "Name>"; echo -n " (leave blank for none): "; $reed NAME; echo ""
        echo "Email>"; echo -n " (leave blank for none): "; $reed EMAIL; echo ""
        echo "Subject>"; echo -n " (leave blank for none): "; $reed SUB; echo ""
        echo "Bump>"; echo -n " (1 or 0): "; $reed BUMP; echo ""
        echo "URL of thread(s)>"; echo -n " (eg. 1993711 123345 or 0 for new threads): "; $reed URL ;echo ""
        while true
        do
        for url in $URL
        do
        echo -n "." >> $IMAGE
        echo [$NUM] [$IMAGE - $PWD] ; echo ""  ; echo -n " >> "
	curl -s -S -A Mozilla/4.0 -F "task=post" -F "parent=$URL" -F "field1=$NAME" -F "field2=$EMAIL" -F "field3=$SUB" -F "field4=$COMMENT" -F "file=@$IMAGE" -F "bumpcheck=$BUMP" -F "password=$PWD" $BOARD  | awk '/wakaba.html/ {print "Successfully uploaded!"} /Upload something smaller/ {print "File too big."} /Either this image is too big or there is no image at all/ {print "File too big or no file selected."} /Cannot find reply/ {print "Cannot find reply."} /Upload failed/ {print "Upload failed."} /Cannot find record/ {print "Cannot find record."} /No verification code on record/ {print "No verification code on record."} /Wrong verification code entered/ {print "Wrong verification code."} /File format not supported/ {print "File format not supported."} /String refused/ {print "String refused."} /Unjust POST/ {print "Unjust POST."} /No file selected/ {print "No file selected."} /No comment entered/ {print "No comment entered,"} /Too many characters in text field/ {print "Text field too long."} /Posting not allowed/ {print "Posting not allowed."} /Abnormal reply/ {print "Abnormal reply smaller"} /Host is banned/ {print "Banned."} /Proxy is banned for being open/ {print "Proxy banned."} /Flood detected, post discarded/ {print "Flood detected, post discarded."} /Flood detected, file discarded/ {print "Flood detected, file discarded."} /Flood detected/ {print "Flood detected."} /Open proxy detected/ {print "Proxy detected."} /This file has already been posted/ {print "Duplicate file detected."} /A file with the same name already exists/ {print "Duplicated file name detected."} /Thread does not exist/ {print "Thread does not exist."} /Possible virus-infected file/ {print "Possible virus-infected file."} /Could not write to directory/ {print "Could not write to server dir."} /Spammers are not welcome here/ {print "Spammer detected."} /SQL connection failure/ {print "SQL connection failure."} /Critical SQL problem!/ {print "Critical SQL problem."}'
        let "NUM += 1"
        echo ""; echo " * Waiting $SLEEP seconds..."; echo ""
        #let "SLEEP = SLEEP + $RANDOM % 5"  #im not a script, srsly u guise lolol
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
        echo "URL of thread>"; echo -n " (eg. 1993711 or 0 for new threads): "; $reed URL ;echo ""
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
        echo ""; echo "[$NUM] [" $(ls -sphd "$file") $(echo "$URL]") ; echo ""  ; echo -n " >> "
	curl -s -S -A Mozilla/4.0 -F "task=post" -F "parent=$URL" -F "field1=$NAME" -F "field2=$EMAIL" -F "field3=$SUB" -F "field4=$COMMENT" -F "file=@$file" -F "password=$PWD" $BOARD | awk '/wakaba.html/ {print "Successfully uploaded!"} /Upload something smaller/ {print "File too big."} /Either this image is too big or there is no image at all/ {print "File too big or no file selected."} /Cannot find reply/ {print "Cannot find reply."} /Upload failed/ {print "Upload failed."} /Cannot find record/ {print "Cannot find record."} /No verification code on record/ {print "No verification code on record."} /Wrong verification code entered/ {print "Wrong verification code."} /File format not supported/ {print "File format not supported."} /String refused/ {print "String refused."} /Unjust POST/ {print "Unjust POST."} /No file selected/ {print "No file selected."} /No comment entered/ {print "No comment entered,"} /Too many characters in text field/ {print "Text field too long."} /Posting not allowed/ {print "Posting not allowed."} /Abnormal reply/ {print "Abnormal reply smaller"} /Host is banned/ {print "Banned."} /Proxy is banned for being open/ {print "Proxy banned."} /Flood detected, post discarded/ {print "Flood detected, post discarded."} /Flood detected, file discarded/ {print "Flood detected, file discarded."} /Flood detected/ {print "Flood detected."} /Open proxy detected/ {print "Proxy detected."} /This file has already been posted/ {print "Duplicate file detected."} /A file with the same name already exists/ {print "Duplicated file name detected."} /Thread does not exist/ {print "Thread does not exist."} /Possible virus-infected file/ {print "Possible virus-infected file."} /Could not write to directory/ {print "Could not write to server dir."} /Spammers are not welcome here/ {print "Spammer detected."} /SQL connection failure/ {print "SQL connection failure."} /Critical SQL problem!/ {print "Critical SQL problem."}'
        let "NUM += 1"
        let "NUM += 1"
        echo ""; echo " * Waiting $SLEEP seconds..."
        sleep $SLEEP
        continue
        done
        ;;
count|coun|cou|co|c)
        echo "Select thread(s) to count images>" ; echo -n " (eg. 111941 112013 112151): " ; $reed threads; echo ""
        while true; do
        for thread in $threads; do
        echo ""; echo "                               images in $CHAN's /$iboard/ $thread"
        echo "________________________________________________________________________________________________________,"
        echo "   5|  10|  15|  20|  25|  30|  35|  40|  45|  50|  55|  60|  65|  70|  75|  80|  85|  90|  95| 100| 105|"
##################
HTML="http://wtfux.org/$iboard/res/$thread.html"
##################
        curl -s -A $useragent --max-time $timeout $HTML | awk '/File :/ {printf "|"}'
        sleep 1;
        done
        done
        ;;
*)
        wtfux
        ;;
esac
}
#################################################
################ end of wtfux() #################
#################################################


echo "Select a chan > "
echo -n " (4chan,7chan,wtfux,420chan): "; $reed CHAN
case "$CHAN" in
     4chan|4ch|4)
           CHAN=4chan
           fourchan
           ;;
     7chan|7ch|7)
           CHAN=7chan
           sevenchan
	   ;;
     420chan|420ch|420)
           CHAN=420chan
           boringchan
	   ;;
     wtfux|wtf|w)
           CHAN=wtfux
           wtfux
	   ;;
     *)
	   echo "What?"
           ;;
esac

echo ""; echo "Done."
