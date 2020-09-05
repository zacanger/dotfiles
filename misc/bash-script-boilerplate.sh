#!/usr/bin/env bash

set -e

# ${0##*/} -- this script's name
# this sets up the script's full path
pushd $(dirname $0) > /dev/null
SCRIPTPATH=$(pwd)
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

# 0;30 Black
# 0;33 Brown
# 0;35 Purple
# 0;37 Light Gray
# 1;30 Dark Gray
# 1;31 Light Red
# 1;32 Light Green
# 1;34 Light Blue
# 1;35 Pink
# 1;36 Light Cyan
red='\033[1;31m'    # bold red
green='\033[1;32m'  # bold green
yell='\033[1;33m'   # bold yellow
blue='\033[1;34m'   # bold blue
purp='\033[1;35m'   # bold purple
cyan='\033[1;36m'   # bold light blue
white='\033[1;37m'  # bold white
reset='\033[0m'     # return the prompt to orig

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
debug() {
  [ "$DEBUG" ] && echo ">>> $*"
}

# if we need a password
get_password() {
  until [ "$password" = "$rpassword" -a -n "$password" ]; do
    read -s -p "Enter a password for user '$1' : " password; echo >&2
    read -s -p "Reenter password for user '$1' : " rpassword; echo >&2
  done
  echo "$password"
}
# pw=$(get_password "${1:-blah}")
# echo "password is '$pw'"

help() {
    cat << EOF
Usage: myscript <help|command> (arguments)

VERSION: 1.0

Available Commands

    help - print this message

EOF
}

join() {
  local IFS="$1"
  shift
  echo "$*"
}

read_params() {
 while test $# -gt 0; do
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

# check os
get_platform() {
  platform='unknown'
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    platform='linux'
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    platform='mac'
  elif [[ "$OSTYPE" == "cygwin" ]]; then
    platform='cygwin'
  elif [[ "$OSTYPE" == "msys" ]]; then
    platform='mingw'
  elif [[ "$OSTYPE" == "win32" ]]; then
    platform='win32'
  elif [[ "$OSTYPE" == "freebsd"* ]]; then
    platform='bsd'
  elif [[ "$OSTYPE" == "openbsd"* ]]; then
    platform='bsd'
  elif [[ "$OSTYPE" == "netbsd"* ]]; then
    platform='bsd'
  else
    # Hopefully we didn't end up here...
    if [ "$(uname)" == "Darwin" ]; then
      platform='mac'
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      platform='linux'
    elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
      platform='windows'
    elif [ "$(uname -s)" == "NetBSD" ]; then
      platform='bsd'
    elif [ "$(uname -s)" == "OpenBSD" ]; then
      platform='bsd'
    elif [ "$(uname -s)" == "FreeBSD" ]; then
      platform='bsd'
    fi
  fi

  echo $platform
}

# Default to No if the user presses enter without giving an answer:
# if ask "Do you want to do such-and-such?" N; then echo "Yes"; else echo "No"; fi
# Only do something if you say Yes
# if ask "Do you want to do such-and-such?"; then said_yes; fi
# Only do something if you say No
# if ! ask "Do you want to do such-and-such?"; then said_no; fi
# Or if you prefer the shorter version:
# ask "Do you want to do such-and-such?" && said_yes
# ask "Do you want to do such-and-such?" || said_no
ask() {
  local prompt default reply

  while true; do
    if [ "${2:-}" = "Y" ]; then
      prompt="Y/n"
      default=Y
    elif [ "${2:-}" = "N" ]; then
      prompt="y/N"
      default=N
    else
      prompt="y/n"
      default=
    fi

    # Ask the question (not using "read -p" as it uses stderr not stdout)
    echo -n "$1 [$prompt] "

    # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
    read reply </dev/tty

    # Default?
    if [ -z "$reply" ]; then
      reply=$default
    fi

    # Check if the reply is valid
    case "$reply" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
    esac

  done
}


# 'types'

is_dir() {
  [[ -d $1 ]]
}

is_empty() {
  [[ -z $1 ]]
}

is_file() {
  [[ -f $1 ]]
}

is_not_empty() {
  [[ -n $1 ]]
}

# if it_exists foo ; then (do things)
it_exists() {
  command -v "$1" &> /dev/null ;
}

die() {
  echo -e $1; exit 1
}

# depends foo bar
depends() {
  for cmd in $@; do
    which $cmd &> /dev/null || die "Error: Required command '$cmd' is missing."
  done
}
