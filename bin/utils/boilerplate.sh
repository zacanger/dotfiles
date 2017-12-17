#!/usr/bin/env bash

set -e

# this sets up the script's full path
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd`
popd > /dev/null

# colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

main() {
 # do stuff here
  echo hello
}

# try, catch, throw, error-handling in a useful kind of way

try() {
  [[ $- = *e* ]]; SAVED_OPT_E=$?
  set +e
}

throw() {
  exit $1
}

catch() {
  export ex_code=$?
  (( $SAVED_OPT_E )) && set +e
  return $ex_code
}

throw_errors() {
  set -e
}

ignore_errors() {
  set +e
}

NORMAL=$(tput sgr0)
GREEN=$(tput setaf 2; tput bold)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)

# red "The configuration file does not exist"
red() {
  echo -e "$RED$*$NORMAL"
}

# green "Task has been completed"
green() {
  echo -e "$GREEN$*$NORMAL"
}

# yellow "You have to use higher version."
yellow() {
  echo -e "$YELLOW$*$NORMAL"
}

# debug "Trying to find config file"
debug() { [ "$DEBUG" ] && echo ">>> $*"; }

# if we need a password
getpassword() {
  until [ "$password" = "$rpassword" -a -n "$password" ]; do
    read -s -p "Enter a password for user '$1' : " password; echo >&2
    read -s -p "Reenter password for user '$1' : " rpassword; echo >&2
  done
  echo "$password"
}
pw=`getpassword "${1:-blah}"`
# echo "password is '$pw'"

help() {
    cat << EOF
Usage: myscript <help|command> (arguments)

VERSION: 1.0

Available Commands

    help - print this message

EOF
}

join() { local IFS="$1"; shift; echo "$*"; }

read_params() {
 while test $# -gt 0
  do
    case "$1" in
        --opt1) echo "option 1"
            ;;
        --opt2) echo "option 2"
            ;;
        --*) echo "bad option $1"
            ;;
        *) echo "argument $1"
            ;;
    esac
    shift
 done
}

# default values example
# URL=${URL:-http://localhost:8080}

# checking the length of strings
# ${#authy_api_key}

read_params $@
main

