#!/usr/bin/env bash

# dashes - script to print out a separator line in term
# Copyright (C) 2013, 2014 by Yu-Jie Lin, MIT
# renamed, because `-` is stdin...
# and `dash` is a shell...
# so that was all kinds of not okay.

VERSION=0.2.0

declare -A CTBL

CTBL=(
  [k]='0m'    [black]='0m'  [bk]='0;1m'    [brightblack]='0;1m'
  [r]='1m'      [red]='1m'  [br]='1;1m'      [brightred]='1;1m'
  [g]='2m'    [green]='2m'  [bg]='2;1m'    [brightgreen]='2;1m'
  [y]='3m'   [yellow]='3m'  [by]='3;1m'   [brightyellow]='3;1m'
  [b]='4m'     [blue]='4m'  [bb]='4;1m'     [brightblue]='4;1m'
  [m]='5m'  [magenta]='5m'  [bm]='5;1m'  [brightmagenta]='5;1m'
  [c]='6m'     [cyan]='6m'  [bc]='6;1m'     [brightcyan]='6;1m'
  [w]='7m'    [white]='7m'  [bw]='7;1m'    [brightwhite]='7;1m'
)

help() {
  echo "Usage: $(basename $0) [OPTION]...

Options:
  -c  separator character
  -u  separator character to '─'
  -f  fgdcolor
  -b  bg color
  -M  do not move cursor up
  -v  version
  -h  halp

Colors: ${!CTBL[@]}, or something like '1;33m'
" | fold
}

W=$(tput cols)
printf -v SEP '%*s' $W
C='-'

while getopts :c:uf:b:Mvh opt; do
  case $opt in
    c)
      C=$OPTARG
      ;;
    u)
      C='─'
      ;;
    f)
      F=3${CTBL[$OPTARG]}
      [[ $F = 3 ]] && F=$OPTARG
      ;;
    b)
      B=4${CTBL[$OPTARG]}
      [[ $B = 4 ]] && B=$OPTARG
      ;;
    M)
      M=1
      ;;
    v)
      echo "$(basename -- "$0") $VERSION"
      exit 0
      ;;
    h)
      help
      exit 0
      ;;
    *)
      help
      exit 1
      ;;
  esac
done

[[ $M ]] || echo -ne "\e[1F"
[[ $F ]] && echo -ne "\e[$F"
[[ $B ]] && echo -ne "\e[$B"
SEP="${SEP// /$C}"
echo "${SEP::W}"
[[ $F ]] || [[ $B ]] && echo -ne "\e[0m" || :

