#!/usr/bin/env bash

# super simple slides script
# usage: slides.sh path/to/slides.md
# slides.md should be a tiny subset of markdown:
# only single hash (h1) headings and body are supported
# headlines will be printed huge with toilet
# body will be printed as-is

file="$1"

hnum=0

# This is for use by toilet and fmt( center text )
columns=$(tput cols)

# Hack to get the pause before next slide working
exec 3<&0

if [ ! -f "$file" ]
then
  echo 'Slides not found!'
  exit 1
fi

if ! hash toilet 2>/dev/null
then
  heading_c="figlet -f script -w $columns -c"
else
  heading_c="toilet --gay -w $columns"
fi

printheading() {
  clear && printf "\n\n\n\n" && $heading_c "$*" | cat && printf "\n\n"
}

printline() {
  echo "$*" | fmt -c -w $columns
}

# do the thing
while IFS= read line
do
  beg=${line:0:1}
  # Check for heading
  if [ "$beg" = "#" ]
  then
    heading=("${line[@]:1}")
    # Cannot do normal read as it just considers read from the file
    if [ "$hnum" -eq 1 ]
    then
      read choice <&3
    fi
    hnum=1
    printheading "$heading"
  else
    printline "$line"
  fi
done < "$file"

# Final wait befor going back to the shell
read choice <&3
clear
