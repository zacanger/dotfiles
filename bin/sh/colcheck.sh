#!/usr/bin/env bash

#The MIT License (MIT) {{{
#
#Copyright (c) 2013-2014 rcmdnk
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of
#this software and associated documentation files (the "Software"), to deal in
#the Software without restriction, including without limitation the rights to
#use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
#the Software, and to permit persons to whom the Software is furnished to do so,
#subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
#FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
#COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
#IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
#CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#}}}

cols=(black red green yellow blue magenta cyan white)

back=-1
if [ "$#" -ne 0 ];then
  for i in $(seq 0 $((${#cols[@]}-1)));do
    if [ "$1" = ${cols[$i]} ];then
      back=$1
      break
    fi
  done
  if [ "$back" -eq -1 ];then
    back=$1
  fi
fi
if [ "$back" -eq -1 ];then
  back=0
fi

for i in {0..255}; do
  num=$(printf "%03d" $i)
  printf " \e[48;05;%d;38;05;%dm%s\e[m" "$back" "$i" "$num"
  if [ $((i%16)) -eq 15 ];then
    echo
  fi
done

echo ''
echo 'Use like:'
echo '    $ col=1'
echo '    $ words="red color"'
echo '    $ printf "\e[38;05;${col}m${words}\e[m"'
col=1
words="red color"
printf "    \e[38;05;%dm%s\e[m" "$col" "$words"
echo
