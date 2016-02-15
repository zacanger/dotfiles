#!/bin/sh

# opens thunar and sets its selection to the given file.
# equivalent to rox's -s/--show or ms explorer's /select,file.
# this assumes that the file is visible to thunar - dotfiles may not work.

# if misc-full-path-in-title is enabled, will also focus relevant window
# instead of opening new one, if such window exists.

file=$1
file="${file/#\~/$HOME}" #expand tilde to $HOME
file=${1%/} #remove trailing slash

if [ -z "$file" ]; then
    echo 'No file selected. Aborting.' 1>&2
    exit 1
fi

if ! command -v thunar &>/dev/null; then
    echo 1>&2 'Thunar not found. Aborting.'
    exit 1
fi

if ! command -v xdotool &>/dev/null; then
    echo 1>&2 'xdotool not found. Aborting.'
    exit 1
fi

if [ -d "$file" ]; then
    window_id=`xdotool search --onlyvisible --name "$file" | head -n1`
    if [ -z $window_id ]; then
        thunar "$file" &
    else
        xdotool windowactivate "$window_id"
    fi
else
    if [ ! -f "$file" ]; then
        echo 'File does not exist. Aborting.' 1>&2
        exit 1
    fi

    dir="$(dirname "$file")"
    window_id=`xdotool search --onlyvisible --name "$dir" | head -n1`
    if [ -z $window_id ]; then
        thunar "$dir" --name "thunar $file" &
        window_id=`xdotool search --sync --onlyvisible --classname "thunar $file" | head -n1`
    fi
    xdotool windowactivate "$window_id"
    xdotool keyup Shift_L Shift_R Control_L Control_R Meta_L Meta_R Alt_L Alt_R Super_L Super_R Hyper_L Hyper_R \
    xdotool key 'ctrl+s'
    xdotool type --delay 0 "$(basename "$file")"
    xdotool key Return
fi
