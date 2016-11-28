#!/usr/bin/env bash

if [[ $# -eq 0 || $# -eq 1 ]] ; then
  echo "remind.sh usage:"
  echo "remind.sh time reminder"
  echo "example:"
  echo "remind.sh 18:00 'do the thing'"
fi

timespec=$1
shift

echo "
    DISPLAY=$DISPLAY zenity --info --text \"$*\" 2>/dev/null ||
    echo -e \"\\a\\n\\n*** REMINDER ***\\n$*\\n****************\\n\" |
    tee `tty`
" |
at "$timespec" 2>&1 |
tail -n +2
