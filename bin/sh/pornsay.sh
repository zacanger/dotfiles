#!/bin/bash

# You're going to love this.
# Pulls in porn titles from crummy porn sites, and then spits them out with ponysay and text-to-speech

# Args:
#  -a or --all: Read all lines at once
#  -r or --rebuild: Rebuild the porn stash and run
#  -p or --purge: Hide the porn stash! (Removes it from disk)
#  -c or --count: Outputs the number of titles in the porn stash.

# TODO Add pornerbros.com

PORN_STASH=~/.pornsay_stash
REFRESH_TIME=$(expr 5 \* 60)
READALL= # False

STASH_PORN() {
	PORNCOM=$(lynx -dump porn.com | tr "\\n" " " | sed -e "s/\*/\n\*/g" | grep -E "\*.*[0-9]*%" | sed -e "s/.*\]//" | head -n -1 | sed -e "s/ \+/ /g" | sed -e "s/ \./\./g" | sed -e "s/[0-9]\+ \(hour\|min\|[A-Za-z]{3} [0-9]+,\).*//")"\n"

	PORNHUB=$(lynx -dump pornhub.com | tr "\\n" " " | sed -e "s/\*/\n\*/g" | grep -E "\*.*\(BUTTON\)" | sed -e "s/.*\]\(.*\)\s*(BUTTON).*/\1/" | sed -e "s/ \+/ /g" | sed -e "s/ \./\./g")"\n"

	REDTUBE=$(lynx -dump redtube.com | grep -E "^\[" | sed -e "s/.*\]//")"\n"
	
	FAPDU=$(lynx -dump fapdu.com | grep -E "Watch the video.*\"$" | sed -e "s/.* \"\(.*\)\"/\1/")"\n"

	FUCKTUBE=$(lynx -dump FUCKtube.com | tr "\\n" " " | sed -e "s/\*/\n\*/g" | grep -E "\*.*[0-9]{1,3}%" | sed -e "s/.*\]//" | sed -e "s/[0-9]*\.*[0-9]*%.*//" | sed -e "s/ \+/ /g" | sed -e "s/ \./\./" | head -n -1)"\n"

	PORN=$PORNCOM$PORNHUB$REDTUBE$FAPDU$FUCKTUBE
	PORN=$(echo "$PORN" | sed -e "s/\&/and/g")

	echo -e "$PORN" > "$PORN_STASH"
}

HIDE_PORN() {
	rm -f $PORN_STASH
}

GET_LINE() {
	LINE=$(echo "$PORN" | head -n $1 | tail -n 1)
}

FAP() {
	clear
	ponysay "$SAY" -bround
	echo $SAY | festival --tts
	#espeak "$SAY" -p 75 -a 200 > /dev/null 2>&1
}

while test $# -gt 0; do
	case "$1" in
		-a|--all)
			READALL=true
			shift
			;;
		-r|--rebuild)
			HIDE_PORN
			shift
			;;
		-p|--purge)
			HIDE_PORN
			exit 0
			;;
		-c|--count)
			if [[ ! -a $PORN_STASH ]]; then
				echo 0
			else
				cat "$PORN_STASH" | wc -l
			fi

			exit 0
			;;
		*)
			break
			;;
	esac
done

if [[ ! -a $PORN_STASH ]]; then
	touch "$PORN_STASH"
	STASH_PORN
fi

MOD_TIME=$(expr $(date +%s) - $(stat -c %Y $PORN_STASH))
if [[ $MOD_TIME -gt $REFRESH_TIME ]]; then
	STASH_PORN
else
	PORN=$(cat $PORN_STASH)
fi

COUNT=$(echo "$PORN" | wc -l)

if [[ ! $READALL ]]; then
	LINE_NUMBER=$(expr $RANDOM % $COUNT + 1)

	GET_LINE $LINE_NUMBER
	SAY=$LINE

	FAP
else
	for I in $(seq 1 $COUNT); do
		GET_LINE $I
		SAY=$LINE

		FAP
	done
fi
