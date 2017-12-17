#!/bin/bash

#
# --------------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# guelfoweb@gmail.com wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return Gianni 'guelfoweb' Amato
# --------------------------------------------------------------------------------
#

# DEPENDENCIES
INOTIFY=$( which inotifywatch )
if [ -z "$INOTIFY" ]; then
  echo "Please install inotify-tools."
  exit
fi

# FUNCTIONS
message(){
  exec 3> >(zenity --notification --listen)
  echo "message: $MESSAGE" >&3
  exec 3>&-
}

# MAIN
MY_REMOTE_IP=`wget -q api.wipmania.com -O - | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'`
MY_LOCAL_IP=`ifconfig | grep -Eo 'inet(:)?( addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
if [ "$MY_REMOTE_IP" ]; then
  MESSAGE="Remote IP: $MY_REMOTE_IP - Local IP: $MY_LOCAL_IP"
  message
elif [ "$MY_LOCAL_IP" ]; then
  MESSAGE="Local IP: $MY_LOCAL_IP"
  message
else
  MESSAGE="No network."
  message
fi
