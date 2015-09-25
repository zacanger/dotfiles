#!/bin/bash

# bbqsetup - runs a few tasks to set up the user environment
# setxkbmap, ceni, tzdata, alsamixer

. /usr/share/doc/dialog/examples/setup-vars
. /usr/share/doc/dialog/examples/setup-tempfile

dialog --backtitle "BBQsetup" --title "Set Keyboard Map" --inputbox "Hello and welcome to LinuxBBQ. Please enter the short name of your keyboard layout, for example de, us, fr, it:" 0 0 2> $tempfile

setxkbmap `cat $tempfile`

sudo ceni
sudo dpkg-reconfigure tzdata
alsamixer
