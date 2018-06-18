# also see getcolour
setupcolours() {
  if [[ ${_COLOURSDEFINED:-0} -ne 1 ]] ; then
    export _BLACK="[0;30m"
    export _BLUE="[0;34m"
    export _GREEN="[0;32m"
    export _CYAN="[0;36m"
    export _RED="[0;31m"
    export _PURPLE="[0;35m"
    export _BROWN="[0;33m"
    export _LIGHTGREY="[0;37m"
    export _DARKGREY="[1;30m"
    export _LIGHTBLUE="[1;34m"
    export _LIGHTGREEN="[1;32m"
    export _LIGHTCYAN="[1;36m"
    export _LIGHTRED="[1;31m"
    export _LIGHTPURPLE="[1;35m"
    export _YELLOW="[1;33m"
    export _WHITE="[1;37m"
    export _NORMAL="[0m"
    export _RESET="$NORMAL"

    # effects
    export _BRIGHT="[1m"
    export _DIM="[2m"
    export _UNDERLINE="[4m"
    export _BLINK="[5m"
    export _REVERSE="[7m"
    export _HIDDEN="[8m"

    export _COLOURSDEFINED=1
  fi
}

setupcolours
