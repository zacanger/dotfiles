#!/usr/bin/env bash

# http://lindi.iki.fi/lindi/xcutselprin

show_container() {
  name="$1"
  cmd="$2"
  escaped_data="`$cmd | cat -A | tr -d '\n' | cut --bytes=1-70`"
  echo "$name: \"$escaped_data\""
}

for i in primary secondary clipboard
do
  show_container $i "xclip -o -selection $i"
done

for i in `seq 0 7`
do
  show_container cut$i "xcb -p $i"
done
