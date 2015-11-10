#!/bin/sh

# print your global IP
# depends on the lynx text browser

# services:
# http://icanhazip.com/
# http://curlmyip.com/
# https://ip.appspot.com/

hash lynx &>/dev/null || { echo "Cannot find lynx"; exit 1; }

lynx -dump http://curlmyip.com/
