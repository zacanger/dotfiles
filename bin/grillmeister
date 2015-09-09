#!/bin/bash

INPUT=/tmp/input.$$

if [[ $UID -ne 0 ]]; then
    echo "$0 must be run as root"
    exit 1
fi

createblock(){
cat <<EOF >> /etc/apt/preferences.d/11grillmeister

Package: libgtk-3-0
Pin: release *
Pin-Priority: -1

EOF
echo "gtk3 now blocked. Well done!"
exit 0
}

removeblock(){
rm /etc/apt/preferences.d/11grillmeister
echo "gtk3 applications can be installed. Bye!"
}

dialog --backtitle "LinuxBBQ Grillmeister" --title "Prevent GTK3-packages from being installed." --menu " " 0 0 0 y "create preferences file" n "remove preferences file" x "Exit" 2>"${INPUT}"

menuitem=$(<"${INPUT}")
case $menuitem in
	y) createblock ;;
	n) removeblock ;;
	x) exit 0 ;;
esac
