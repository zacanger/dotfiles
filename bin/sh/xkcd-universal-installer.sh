#!/bin/bash

# usage: ./installer.sh 1 pkgname
# first arg is package manager
# second arg is pkg, url, etc.
# see: https://xkcd.com/1654

if [ $# -ne 2 ]; then
  echo
  echo "    Usage: ${0} <type> {package name[1-11], dir[13], url[14]}"
  echo "       ie. ${0} 5 php-fpm"
  echo
  echo "types follow..........."
  echo
  echo "1 pip install"
  echo "2 easy_install"
  echo "3 brew install"
  echo "4 npm install"
  echo "5 yum install"
  echo "6 dnf install"
  echo "7 docker run"
  echo "8 pkg install"
  echo "9 apt-get install"
  echo "10 sudo apt-get install"
  echo "11 steamcmd +app_update"
  echo "12 git clone"
  echo "13 make"
  echo "14 curl"
  exit 1
fi

if [ "$1" == "" ]; then
  echo
  echo "types follow..........."
  echo
  echo "1 pip install"
  echo "2 easy_install"
  echo "3 brew install"
  echo "4 npm install"
  echo "5 yum install"
  echo "6 dnf install"
  echo "7 docker run"
  echo "8 pkg install"
  echo "9 apt-get install"
  echo "10 sudo apt-get install"
  echo "11 steamcmd +app_update"
  echo "12 git clone"
  echo "13 make"
  echo "14 curl"
  echo
  echo "What type do you wish to use?"
  read ITYPE
else
  ITYPE=$1
fi

case $ITYPE in
  1)
    CMD="pip install $2"
    ;;
  2)
    CMD="easy_install $2"
    ;;
  3)
    CMD="brew install $2"
    ;;
  4)
    CMD="npm install $2"
    ;;
  5)
    CMD="yum install $2"
    ;;
  6)
    CMD="dnf install $2"
    ;;
  7)
    CMD="docker run $2"
    ;;
  8)
    CMD="pkg install $2"
    ;;
  9)
    CMD="apt-get install $2"
    ;;
  10)
    CMD="sudo apt-get install $2"
    ;;
  11)
    CMD="steamcmd +app_update $2 validate"
    ;;
  12)
    CMD="git clone https://github.com/$2/$2"
    ;;
  14)
    CMD="cd $2; ./configure ; make ; make install"
    ;;
  15)
    CMD="curl $2 | bash"
    ;;
  *)
    echo "Not a valid choice luser"
    exit
    ;;
esac

exec ${CMD}
