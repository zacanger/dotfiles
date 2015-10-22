#!/bin/bash

# Set codec options
if [ "$3" = opus ]; then
    export CODEC="opus -q 128"
elif [ "$3" = ogg ]; then
    export CODEC="ogg -q 6"
elif [ "$3" = mp3 ]; then
    export CODEC="mp3"
elif [ "$3" = flac ]; then
    export CODEC="flac"
else
    echo "Syntax: batchenc INPUTDIR OUTPUTDIR {opus,ogg,flac,mp3}"
    exit 1
fi

read -p "Source directory is \""$1"\". Is this correct? > " yn
case $yn in
    [Yy]* ) : ;;
    [Nn]* ) exit ;;
    * ) echo "Please answer yes or no.";;
esac

read -p "Target directory is \""$2"\". Is this correct? > " yn
case $yn in
    [Yy]* ) : ;;
    [Nn]* ) exit ;;
    * ) echo "Please answer yes or no.";;
esac


OPWD="$PWD"
inputDir=$(echo "$1" | sed 's/\/$//')
outputDir=$(echo "$2" | sed 's/\/$//')

if [ ! -d "$inputDir" ]; then
  echo "Error: $inputDir: no such directory" 1>&2
  exit 1
elif [ ! -d "$outputDir" ]; then
  echo "Error: $outputDir: no such directory" 1>&2
  exit 1
fi

cd "$outputDir"
while IFS= read -d $'\0' directory; do
  if [ ! -d "${inputDir}/${directory}" ]; then
    echo "Deleting \"${outputDir}/${directory}\""
    rm -rf "${outputDir}/${directory}"
  fi
done < <( find . -type d -print0 2>/dev/null )

cd "$inputDir"
while IFS= read -d $'\0' directory; do
  if [ ! -d "${outputDir}/${directory}" ]; then
    ls "${directory}"/*.flac >/dev/null 2>&1 || continue
    echo "Transcoding \"${directory}\""
    # transcode to CODEC
    caudec -O "${outputDir}/${directory}" -K -s -c $CODEC "${directory}"/*.flac
  fi
done < <( find . -type d -print0 2>/dev/null )

cd "$OPWD"
