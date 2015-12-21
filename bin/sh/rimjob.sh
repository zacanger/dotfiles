#!/bin/bash

# rimjob.sh - ENTERPRISE QUALITY BASH SCRIPT
# last update: 31.01.2010 -  Version 0.9
# direct cool stories, monnies, bug reports, etc. to blargh on #/g/tv - Rizon or blargh.macfag@googlemail.com
#
# improved rape.sh script (v5) => http://pastebin.com/f70ec1e29
#
# creates automagically new threads
# posts old thread URL into new thread and vice versa
# self tuning sleep timer to avoid flood
# uploads biggest files at first to avoid flood protection kicking in too early (default)
# to upload your shit sorted by name add -s as option

# todo:
# handle curl failures properly
# use variables for colorcodes
# add some curl timeouts

##### CHECK IF CURL IS AVAILABLE
CURL=`which curl`
if [ -z "$CURL" ]; then
	echo "This script depends on curl, make sure it's installed and in your path."
	exit 1
fi

##### CHANGE ME 
USERAGENT="furryfox"
PWD=asd27s40
SLEEP=10
##### YOU MAY CHANGE THIS TOO
TMP=`mktemp -t rimjob.curlout.XXXX`
TMP2=`mktemp -t rimjob.lsout.XXXX`
##### OMG WTF ARE YOU DOING??
BIFS=$IFS; SUM=0; CNT=1; DUP=0; UPD=0; DRP=0; TRD=1; FLR=0; COMMENT=""; COMMENT2=$COMMENT

replies() {
	cat $TMP | awk '/Post successful!/ {print "POST SUCCESSFUL!"} /Error: Duplicate file entry detected./ {print "Duplicate."} /Error: Flood detected./ {print "Flood detected."} /Max limit of/ {print "Max limit reached."} /Abnormal reply/ {print "Abnormal reply."} /Error: No file selected./ {print "No file selected."} /Error: Cannot find record./ {print "Cannot find record."} /Error: No text entered./ {print "No text entered."} /404 - Not Found/ {print "404 - Not found."} /Thread specified does/ {print "Thread does not exist."} /You are banned ;_;/ {print "Banned."} /Error: Field too long./ {print "Field too long."} /Error: File too large./ {print "File too large."} /Detected possible malicious code in image file./ {print "Detected possible malicious code in image file."} /Error: Image resolution is too large./ {print "Image resolution too large."} /Updating index.../ {print "Updating index..."} /Error: Upload failed./ {print "Upload failed."} /Error: Invalid tag specified./ {print "Invalid tag."} /Image file contains embedded archive./ {print "Image contains embedded archive."} /This board doesn/ {print "This board does not exist."}'
}

rim_stats() {
	echo -ne "\nThreads: $TRD\nUploaded: $UPD of $SUM\nDupes: $DUP\nDropped: $DRP (flood)\nFailures: $FLR\n"
}

clean_up() {
	rm -f $TMP $TMP2
}

choose() {
echo -ne "Choose a board >
 (a,b,c,d,e,f,g,gif,h,hr,k,m,o,p,r,s,t,u,v,w,wg,i,ic,cm,y,r9k
  3,adv,an,cgl,ck,co,fa,fit,int,jp,lit,mu,n,new,po,sci,sp,tg,toy,trv,tv,x): "
read -e IBOARD

case "$IBOARD" in
	a|b|c|g|k|m|o|p|v|w|cm|an|ck|co|mu|po|tg|tv|x|gif|h|r|s|t|i|ic|d|e|hr|u|wg|y|cgl|n|r9k|3|adv|int|lit|sci|new)
	ISERVER="boards"
	PSERVER="sys"
	POST="post";;
	f|fk)
	echo -e "\n/$IBOARD/ is not supported\n"
	choose;;
	*)
	echo -e "\n/$IBOARD/ doesn't exist yet :|\n"
	choose;;
esac
}

trap "clean_up; rim_stats; exit 1" 1 2 15

clear
choose

BOARD="http://$PSERVER.4chan.org/$IBOARD/$POST"

echo -ne "\nSelect dir(s) to dump, separate multiple dirs with a semicolon>
 (eg. /users/derp/pics;/users/hurrr/durr derp):\n"
read ADIR
IFS=";"
for DIR1 in $ADIR; do
	IFS=$BIFS
	cd "$DIR1"
	if [ "$1" = "-s" ]; then
		# sorted by name
		ls -1 | sed "s,^\([^/]\),${DIR1}/\1," >> $TMP2; else
		# sorted by size
		ls -1S | sed "s,^\([^/]\),${DIR1}/\1," >> $TMP2
	fi
done

echo
cat $TMP2

SUM=`cat $TMP2 | grep -c .`
echo -ne "\n\033[32m$SUM files selected.\033[m\n"

echo -ne "\nName>
 (leave blank for none): "
read -e NAME
echo -ne "\nEmail>
 (leave blank for none): "
read -e EMAIL
echo -ne "\nSubject>
 (leave blank for none): "
read -e SUB
echo -ne "\nInitial comment>
 (leave blank for none): "
read -e ICOM
echo -ne "\nThread ID>
 (eg. 1993711 or blank for new thread): "
read -e URL

echo -e "\n\n\033[1;34mstarting dump. pause with \033[m\033[34mctrl-s\033[1;34m, continue with \033[m\033[34mctrl-q\033[m"

while read FILE; do
	if [ -d "$FILE" ]; then
		echo -e "\n\033[1;31m * $FILE is a directory.\033[m"
		let "FLR += 1"
		continue
	fi
	if [ ! -f "$FILE" ]; then
		echo -e "\n\033[1;31m * $FILE doesn't exist.\033[m"
		let "FLR += 1"
		continue
	fi
	
	BFILE=`basename "$FILE"`
	SIZE=`du -sh "$FILE" | awk '{print $1}'`
	
##### MAIN DUMPER
	echo -e "\n[$TRD/$CNT/$SUM] [ ($SIZE) $BFILE => http://$ISERVER.4chan.org/$IBOARD/res/$URL ]"
	curl -# -A $USERAGENT -F "resto=$URL" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$ICOM" -F "upfile=@$FILE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" $BOARD > $TMP
	ICOM=""
	ANSW=`replies`
	echo " >> $ANSW"

##### FLOOD DETECTION RETRY #1
	if [ "$ANSW" = "Flood detected." ] || [ "$ANSW" = "Updating index..." ] || [ "$ANSW" = "Upload failed." ] || [ "$ANSW" = "" ]; then
		echo -e "\033[1;31m[Retry #1/2] [ ($SIZE) $BFILE => http://$ISERVER.4chan.org/$IBOARD/res/$URL ]\033[m"
		sleep 7
		if [ "$ANSW" = "Flood detected." ]; then
			let "SLEEP += 5"
		fi
		curl -# -A $USERAGENT -F "resto=$URL" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT" -F "upfile=@$FILE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" $BOARD > $TMP
		ANSW=`replies`
		echo " >> $ANSW"
	fi

##### FLOOD DETECTION RETRY #2
	if [ "$ANSW" = "Flood detected." ]; then
		echo -e "\033[1;31m[Retry #2/2] [ ($SIZE) $BFILE => http://$ISERVER.4chan.org/$IBOARD/res/$URL ]\033[m"
		echo -e "\033[1;35mSET THE SLEEP TIMER A BIT HIGHER IF YOU STILL GET THE FLOOD DETECTED MESSAGE!\033[m"
		sleep 7
		let "SLEEP += 5"
		curl -# -A $USERAGENT -F "resto=$URL" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT" -F "upfile=@$FILE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" $BOARD > $TMP
		ANSW=`replies`
		echo " >> $ANSW"
		if [ "$ANSW" = "Flood detected." ]; then
			let "DRP += 1"
			echo " >> Picture dropped!"
		fi
	fi
	
##### CREATE NEW THREAD WHEN PIC LIMIT IS REACHED, POST A LINK TO THE OLD THREAD IN THE NEW THREAD AND VICE VERSA
	if [ "$ANSW" = "Max limit reached." ]; then
		let "TRD += 1"
		COMMENT="Thread #$TRD
Continued from: >>$URL

$COMMENT2"
		echo -e "\033[1;32m[$TRD/$CNT/$SUM] [ ($SIZE) $BFILE => Creating new thread. ]\033[m"
		curl -# -A $USERAGENT -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=$COMMENT" -F "upfile=@$FILE" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" $BOARD > $TMP
		ANSW=`replies`
		URL2=$URL
		URL=`cat $TMP | egrep -o 'thread:0,no:[0-9]+' | egrep -o '[0-9]{4,}'`
		COMMENT=$COMMENT2
		let "UPD += 1"
		let "CNT += 1"
		echo " >> $ANSW"
		echo -e "\033[32m >> Thread created. Waiting $SLEEP seconds...\033[m"
		sleep $SLEEP
		echo -e "\033[32m >> Posting new thread URL into old thread...\033[m"
		curl -# -A $USERAGENT -F "resto=$URL2" -F "name=$NAME" -F "email=$EMAIL" -F "sub=$SUB" -F "com=Continued here: >>$URL" -F "pwd=$PWD" -F "mode=regist" -F "submit=submit" $BOARD > /dev/null
		sleep $SLEEP
		continue
	fi
	
##### GET THE THREAD URL EVERYTIME A NEW THREAD IS CREATED
	if [ "$URL" = "" ]; then
		URL=`cat $TMP | egrep -o 'thread:0,no:[0-9]+' | egrep -o '[0-9]{4,}'`
	fi
	
##### KEEP POSTING AFTER DUPLICATE
	if [ "$ANSW" = "Duplicate." ]; then
		let "DUP = DUP + 1"
		let "CNT = CNT + 1"
		continue
	fi
	
##### KEEP POSTING IF A NEGLIGIBLE FAILURE OCCURS
	if [ "$ANSW" = "Image resolution too large." ] || [ "$ANSW" = "Cannot find record." ] || [ "$ANSW" = "Abnormal reply." ] || [ "$ANSW" = "Detected possible malicious code in image file." ] || [ "$ANSW" = "Error: File too large." ] || [ "$ANSW" = "Updating index..." ] || [ "$ANSW" = "Upload failed." ] || [ "$ANSW" = "Image contains embedded archive." ]; then
		let "FLR += 1"
		let "CNT += 1"
		continue
	fi
	
##### QUIT SCRIPT AFTER A SERIOUS FAILURE
	if [ "$ANSW" = "No file selected." ] || [ "$ANSW" = "No text entered." ] || [ "$ANSW" = "404 - Not found." ] || [ "$ANSW" = "Thread does not exist." ] || [ "$ANSW" = "Banned." ] || [ "$ANSW" = "Field too long." ] || [ "$ANSW" = "This board does not exist." ]; then
		clean_up
		rim_stats
		exit 1
	fi
	
##### IF CURL FAILS OR 4CHAN REPLY IS NOT SPECIFIED
	if [ "$ANSW" = "" ]; then
		echo -e "\033[1;31mCurl failed or 4chan reply is not specified.\033[m"
		cat $TMP >> $HOME/Desktop/rimjob_debug.txt
		let "FLR += 1"
		continue
	fi
		
let "UPD += 1"
let "CNT += 1"
	if [ "$CNT" -le "$SUM" ]; then
		echo -e "\n * Waiting $SLEEP seconds..."
		sleep $SLEEP
	fi
continue
done < $TMP2
clean_up
rim_stats
exit 0
