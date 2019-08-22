#!/bin/sh

sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
