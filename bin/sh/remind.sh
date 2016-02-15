#!/bin/bash

timespec=$1
shift

echo "
    DISPLAY=$DISPLAY zenity --info --text \"$*\" 2>/dev/null ||
    echo -e \"\\a\\n\\n*** REMINDER ***\\n$*\\n****************\\n\" |
    tee `tty`
" |
at "$timespec" 2>&1 |
tail -n +2
