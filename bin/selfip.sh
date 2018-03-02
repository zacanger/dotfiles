#!/usr/bin/env bash

# curl ifconfig.me
set -e
echo " "
URL='http://dyn.value-domain.com/cgi-bin/dyn.fcg?ip'
if which curl > /dev/null; then
  curl -o - "${URL}"
else
  wget -qO - "${URL}"
fi
echo " "
echo " "