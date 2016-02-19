#!/usr/bin/env bash
set -e

# TODO:
# Check if $FROM or $TO are relative paths and then fix them automatically
# Check if user has write access to $TO to prevent thousands of errors
# Check if user can read from $FROM to prevent thousands of errors
# Add more command-line parameter support (For ffmpeg options?) like "./do.sh -V0 /home/rob1nn/Music /home/rob1nn/Music2"

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
FROM="$1"
TO="$2"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

command -v cpio >/dev/null 2>&1 || { echo >&2 "${RED}I require cpio but it's not installed.${NC} Aborting..."; exit 1; }
command -v ffmpeg >/dev/null 2>&1 || { echo >&2 "${RED}I require ffmpeg but it's not installed.${NC} Aborting..."; exit 1; }

if [ -z "$FROM" ] || [ -z "$TO" ]; then
	#unset
	echo -e "${RED}Parameter(s) missing!${NC} Aborting..."
	echo -e ""
	echo -e "First Argument: Folder to process"
	echo -e "Second Argument: Folder to write into"
	exit 1
fi

function cleanup ()
{
	#remove last file to prevent broken files to be saved
	LASTFILE="$(find $TO -type f -printf '%T@ %P\n' | sort -n | tail | sed -r 's/^.{22}//' | tail -n 1)"
	echo -e "Last modified file (Possibly broken): $LASTFILE"
	echo -e "Removing..."
	(
		cd "$TO"
		rm "$LASTFILE"
	)

	echo -e ""
	echo -e "Cleaning up..."
	find "$TO" -type d -empty -delete #TODO: figure out why too many directorys are created sometimes
	echo -e "Done."
	cd "$DIR"
	echo -e "Exiting..."
}
trap cleanup exit

function wd ()
{
	RMPATH="$(expr ${#FROM} + 2)" #I dont know why, but i have to add 2 here, else $PATH will have two characters not cut off
	CURPATH="$(pwd)"
	PATH="$(echo $CURPATH | cut -c $RMPATH-)"
	echo -e "$PATH/$f"
	#NEWPATH="${PATH//\[FLAC\]/\[V0\]}"
	#echo "$NEWPATH$f" #Return "relative" path with file
}

function copy ()
{
	#copy the file into the output folder
	OUTFILE="$(echo $TO/$(wd))"

	if [ ! -f "$OUTFILE" ]; then
		cp "$f" "$TO/$(wd)"
	else
		echo -e "$OUTFILE exists. Skipping..."
	fi
}

function convert ()
{
	#convert the file into the output folder
	OUTFILE="$(echo $TO/$(wd) | sed 's/.flac/.mp3/g')"
	INFILE="$(echo $f)"

	if [ ! -f "$OUTFILE" ]; then
		ffmpeg -i "$INFILE" -qscale:a 0 "$OUTFILE"
	else
		echo -e "$OUTFILE exists. Skipping..."
	fi
}

function file ()
{
	echo -e "Checking $f"
	if [ ${f: -5} == ".flac" ]; then
		#file is flac
		echo -e "Converting $f to mp3/V0 and copying converted file..."
		convert
	fi
	if [ ${f: -4} == ".mp3" ]; then
		#file is mp3
		echo -e "Copying $f..."
		copy
	fi
	if [ ${f: -5} == ".flac" ] && [ ${f: -4} == ".mp3" ]; then
		#file is something else
		echo -e "Ignoring $f..."
	fi
}

function folder ()
{
	echo -e "Entering folder $f"
	(
		if [ ! -d "$TO/$(wd)" ]; then
			mkdir -p "$TO/$(wd)"
		fi
		cd "$f"
		main
	)
}

function main ()
{
	for f in *; do
		#statements
		echo -e "${RED}Processing $f${NC}";
		if [ -d "$f" ]; then
			if [ -L "$f" ]; then
				echo -e "${CYAN}$f is a symbolic link, ignoring...${NC}"
			else
				echo -e "${BLUE}$f is a directory${NC}"
				folder
			fi
		fi
		if [ -f "$f" ]; then
			echo -e "${GREEN}$f is a regular file${NC}"
			file
		fi
	done
}

(
	echo -e "Preparing..."
	if [ ! -d "$TO" ]; then
		mkdir -p "$TO"
	fi
	#find "$FROM" -type d | cpio -pd "$TO"
	echo -e "Done."

	echo -e "Processing..."
	cd "$FROM"
	main
	echo -e "Done."
)
