#/usr/bin/env bash

while read filename
do
  lame -V2 "$filename" "${filename/.wav}.mp3"
done < <( find "$HOME/Desktop/smarter/Remasters" -name "*.wav" )
