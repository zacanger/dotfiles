#!/usr/bin/env bash

if ! hash inotifywatch 2>/dev/null ; then
  echo 'Please install inotify-tools'
  exit 1
fi

message() {
  exec 3> >(zenity --notification --listen)
  echo "message: $MESSAGE" >&3
  exec 3>&-
}

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
