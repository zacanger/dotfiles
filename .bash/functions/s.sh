# shellcheck shell=bash

# change part of $PWD and cd to it. example:
# /usr/local/lib/python2.7 $ s 2.7 3.5
# /usr/local/lib/python3.5 $

s() {
  local cd="$PWD"
  if [ "$1" = "--complete" ]; then
    awk -v q="${2/s /}" -v p="$PWD" '
    BEGIN {
    split(p,a,"/")
    for( i in a ) if( a[i] && tolower(a[i]) ~ tolower(q) ) print a[i]
    }
    '
  else
    while [ "$1" ]; do
      cd="$(echo "$cd" | sed "s/$1/$2/")"
      shift; shift
    done
    cd "$cd" || return
  fi
}

complete -C 's --complete "$COMP_LINE"' s
