#!/bin/bash
#
# dvolbar - OSD Volume utility 
#
# author - bruenig

#Customize this stuff
IF="Master"         # audio channel: Master|PCM
SECS="1"            # sleep $SECS
BG="#403728"        # background colour of window
FG="#000000"        # foreground colour of text/icon
BAR_FG="#f6e2a7"    # foreground colour of volume bar
BAR_BG="#b09161"    # background colour of volume bar
XPOS="735"          # horizontal positioning
YPOS="1000"          # vertical positioning
HEIGHT="16"         # window height
WIDTH="210"         # window width
BAR_WIDTH="200"     # width of volume bar
ICON=~/.icons/spkr.xbm

#Probably do not customize
PIPE="/tmp/dvolpipe"

err() {
  echo "$1"
  exit 1
}

usage() {
  echo "usage: dvol [option] [argument]"
  echo
  echo "Options:"
  echo "     -i, --increase - increase volume by \`argument'"
  echo "     -d, --decrease - decrease volume by \`argument'"
  echo "     -t, --toggle   - toggle mute on and off"
  echo "     -h, --help     - display this"
  exit
}

#Argument Parsing
case "$1" in
  '-i'|'--increase')
    [ -z "$2" ] && err "No argument specified for increase."
    [ -n "$(tr -d [0-9] <<<$2)" ] && err "The argument needs to be an integer."
    AMIXARG="${2}%+"
    ;;
  '-d'|'--decrease')
    [ -z "$2" ] && err "No argument specified for decrease."
    [ -n "$(tr -d [0-9] <<<$2)" ] && err "The argument needs to be an integer."
    AMIXARG="${2}%-"
    ;;
  '-t'|'--toggle')
    AMIXARG="toggle"
    ;;
  ''|'-h'|'--help')
    usage
    ;;
  *)
    err "Unrecognized option \`$1', see dvol --help"
    ;;
esac

#Actual volume changing (readability low)
AMIXOUT="$(amixer set "$IF" "$AMIXARG" | tail -n 1)"
MUTE="$(cut -d '[' -f 4 <<<"$AMIXOUT")"
if [ "$MUTE" = "off]" ]; then
  VOL="0"
else
  VOL="$(cut -d '[' -f 2 <<<"$AMIXOUT" | sed 's/%.*//g')"
fi

#Using named pipe to determine whether previous call still exists
#Also prevents multiple volume bar instances
if [ ! -e "$PIPE" ]; then
  mkfifo "$PIPE"
  (dzen2 -tw "$WIDTH" -h "$HEIGHT" -x "$XPOS" -y "$YPOS" -bg "$BG" -fg "$FG" < "$PIPE" 
   rm -f "$PIPE") &
fi

#Feed the pipe!
(echo "$VOL" | gdbar -l "^i(${ICON})" -fg "$BAR_FG" -bg "$BAR_BG" -w "$BAR_WIDTH" -s 0 -ss 1 -sw 5 ; sleep "$SECS") > "$PIPE"
