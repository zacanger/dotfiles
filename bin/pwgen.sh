#!/bin/sh
# simple random password generator
# thanks z3bra ! http://git.z3bra.org/scripts/file/mkpasswd.html

# number of characters in the password ( default: 30 )
BYTES=30
# number of passwords to generate ( default: 1 )
NUM=1
# special characters to include in the password
SYM='~!@#$%^&*()_+=.'

usage() {
  echo "usage: ${0##*/} -n <no. of characters> -c <no. of passwords>"
  echo "(without any option a 30 character password is generated)"
  echo
  echo "examples:"
  echo "generate 4 different passwords with 30 characters in each:"
  echo "${0##*/} -n 4 -c 30"
  echo
  echo "generate a 20 character password excluding the '#' and '+' special characters:"
  echo "${0##*/} -c 20 -d '#+'"
}

while [ -n "$1" ]; do
  case $1 in
    -h) # show help message
      usage && exit 0 ;;
    -c) # specify number of characters in the password(s)
      shift; BYTES=$1 ;;
    -n) # specify number of password(s) to generate
      shift; NUM=$1   ;;
    -d) # specify the special characters for exclusion
      shift; SYM="$(echo $SYM | tr -d "$1")" ;;
    *) # rtfm
      usage && exit 1 ;;
  esac
  shift
done

# character set for the password
CHARSET="A-Za-z0-9${SYM}"

tr -cd "$CHARSET" < /dev/urandom | fold -w $BYTES | sed ${NUM}q
# dd count=$NUM bs=$BYTES iflag=fullblock 2> /dev/null | fold -w $BYTES
