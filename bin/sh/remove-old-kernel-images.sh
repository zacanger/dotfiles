#!/bin/bash

# Remove Unused Kernel Images
# (c) Lukasz Grzegorz Maciak
# Sed logic via Ubuntu Genious

clear
echo "Remove Unused Kernel Images"
echo "==========================="

echo -e "\n(c) 2013 Lukasz Grzegorz Maciak\n"

echo -e "This script will remove old, unused kernel images."
echo -e "This may take quite a while so be patient.\n"

kernel=$(uname -r)

echo -e "Your current Kernel version is $kernel\n"
echo -e "Here are unused images installed on your system:\n"

dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d'

echo -e "\n\n"

while true; do

    read -p "Remove these images (y/n)? " reply

    case $reply in

        [Yy]* ) dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge; break;;

        [Nn]* ) exit;;

        * );;
    esac
done
