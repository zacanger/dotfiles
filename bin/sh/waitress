#!/usr/bin/env bash
#
# waitress
# sets preferences 
# |
# +-DPMS
# |   + disable/enable screen blanking
# |   
# +-set active Xresources
# |
# +-kernel
# |   + makes release rolling
# |   + enables PAE support
# |   + changes kernel source
# |
# +-APT
# |   + handling of bug reports
# |   + add aptitude
# |
# +-keymap

show_help (){
	printf "$help_text"
	exit 0
}

help_text="
	Usage:  $0  [option]
	
	valid options:
		-h, --help		show this help
		-f, --force	run application anyway

"

while [[ $1 == -* ]]; do
	case "$1" in

		-h|--help)
			show_help ;;

		-f|--force)
			touch /home/$USER/.local/.waitress
			break ;;
		*)
			print "\t Try: $0 -h for help. \n\n"
			exit 1 ;;
	esac
done

function byebye(){
	rm /home/$USER/.local/.waitress
	exit 0 
}


######### first of all, check if there is a cookie
######### if so, continue
######### if not, byebye

if [ ! -f /home/$USER/.local/.waitress ]
then 
	# the waitress lays an egg so it can be poached
	touch /home/$USER/.local/.waitress
	byebye	
else
	main
fi

####################################################################

####################################################################


INPUT=/tmp/menu.sh.$$

######### start Ceni anyway, no matter what
######### We want to update the base, the user can skip if it fails

dialog --backtitle "LinuxBBQ Waitress" --title "Setting up the network" --msgbox "Welcome to the Pony Muncher! \nFirst, we set up your network using Ceni. \nIf setting up the network fails, no matter - you can change some settings without network connectivity." 12 50

clear

sudo ceni

# bring it up to sync, if not - it bails out.
sudo apt-get update 


function xfcepnl(){
echo "sleep 5s && xfce4-panel &" >> /home/$USER/.config/openbox/autostart
xfce4-panel &
}

function lxpnl(){
echo "sleep 5s && lxpanel &" >> /home/$USER/.config/openbox/autostart
lxpanel &
}

function tpnl(){
echo "sleep 5s && lxpanel &" >> /home/$USER/.config/openbox/autostart
tint2 &
}


function panel(){
dialog --backtitle "LinuxBBQ - Waitress" --title "Panel Configuration" --menu " \n" 0 0 0 \
        d "xfce4-Panel" \
        c "lxpanel" \
	a "tint2" \
        b "Don't bother, skip!" \
        x "Send Waitress away and Exit (not recommended)" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
        d) xfcepnl ;;
        c) lxpnl ;;
        b) main ;;
	a) tpnl ;;
        x) byebye;;
esac
dpms
}


function dpms(){
dialog --backtitle "LinuxBBQ - Waitress" --title "DPMS and Screen Blanking" --menu " \n" 0 0 0 \
        d "Disable screen blanking" \
        c "Configure blanking time" \
        b "Back to Main" \
        x "Send Waitress away and Exit" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	d) dpms_blank ;;
	c) dpms_conf ;;
	b) main;;
	x) byebye;;
esac
dpms
}

function xresources(){
dialog --backtitle "LinuxBBQ - Waitress" --title "Xresources" --menu " \n" 0 0 0 \
	m "Monochrome theme" \
	c "Colorful theme" \
	b "Back to Main" \
        x "Send Waitress away and Exit" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	m) cp /home/$USER/.Xresources_mono /home/$USER/.Xresources ;;
	c) cp /home/$USER/.Xresources_color /home/$USER/.Xresources ;;
	b) main;;
	x) byebye;;
esac
main
}

function kernel(){
dialog --backtitle "LinuxBBQ - Waitress" --title "Kernel Options" --menu " \n" 0 0 0 \
        r "Enable rolling release model" \
        p "Enable PAE kernel and rolling release model" \
        l "Add Liquorix sources and download Liquorix kernel" \
	d "Add Debian vanilla PAE kernel" \
	i "Add Debian vanilla 486 kernel for really old computers" \
        b "Back to Main" \
        x "Send Waitress away and Exit" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	r) rrm;;
	p) pae_rrm;;
	l) liq;;
	d) debkern;;
	i) debkern486;;
	b) main;;
	x) byebye;;
esac
main
}

function bugs(){
dialog --backtitle "LinuxBBQ - Waitress" --title "APT, Aptitude and Bug Handling" --menu " \n" 0 0 0 \
	a "Add APT Listbugs (recommended)" \
	p "Add Aptitude and set as default upgrade method" \
	c "Add command-not-found" \
        b "Back to Main" \
        x "Send Waitress away and Exit" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	a) addlistbugs;;
	p) addaptitude;;
	c) addcnf;;
	b) main;;
	x) byebye;;
esac
main
}

function keymp(){
dialog --backtitle "LinuxBBQ - Waitress" --title "Set keymap" --inputbox "Enter your two-letter country code, for example us for US English, it for Italian, de for German, fr for French, etc... \n" 0 0 2>"${INPUT}"

kmp=$(<"${INPUT}")

echo "setxkbmap $kmp &" >> /home/$USER/.config/openbox/autostart 
main
}

######### sub-functions 

function addlistbug(){
	clear
	sudo apt-get install -y apt-listbugs
kernel
}

function addaptitude(){
        clear
        sudo apt-get install -y aptitude
kernel
}

function addcnf(){
        clear
        sudo apt-get install -y command-not-found
kernel
}


function debkern(){
	clear
	sudo apt-get install -y linux-image-686-pae linux-headers-686-pae
kernel
}

function debkern486(){
        clear
        sudo apt-get install -y linux-image-486 linux-headers-486
kernel
}

function liq(){
	clear
        sudo apt-get install -y linux-image-liquorix-686 linux-headers-liquorix-686
kernel
}

function rrm(){
	clear
	sudo apt-get install -y linux-image-siduction-686 linux-headers-siduction-686
kernel
}

function rrm_pae(){
	clear
        sudo apt-get install -y linux-image-siduction-686-pae linux-headers-siduction-686-pae
kernel
}


function dpms_blank(){
	echo "xset s off" >> /home/$USER/.config/openbox/autostart
	echo "xset -dpms" >> /home/$USER/.config/openbox/autostart
dpms
}

function dpms_conf(){
	dialog --backtitle "LinuxBBQ - Waitress" --title "DPMS Setting" --inputbox "Blank screen after how many seconds? 3600 equals 1 hour. \n" 0 0 2>"${INPUT}"
	blt=$(<"${INPUT}")
	echo "xset +dpms" >> /home/$USER/.config/openbox/autostart
	echo "xset s $blt" >> /home/$USER/.config/openbox/autostart
dpms
}


function wetter(){
        dialog --backtitle "LinuxBBQ - Waitress" --title "Geographical Location" --inputbox "Enter your location as Cityname,COUNTRY (for example: Berlin,DE or Sydney,AU)  \n" 0 0 2>"${INPUT}"
        ansiw=$(<"${INPUT}")
        echo "location:$ansiw" >> /home/$USER/.ansiweatherrc
main
}


function main(){
dialog --backtitle "LinuxBBQ - Waitress" --title "Set your preferences here. If you are unsure, only choose to set your keymap and then exit. You are safe." --menu " \n" 0 0 0 \
	f "Choose a panel first" \
	w "Enter your location for ansiweather script" \
	a "Set your keymap" \
	b "Choose Xresources for terminal applications" \
	c "Set DPMS preferences for screen blanking" \
	d "Configure APT" \
	e "Kernel options and release model" \
	p "Add other software using RoastYourOwn" \
        x "Exit for now..." 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	w) wetter;;
	f) panel;;
	a) keymp;;
	b) xresources;;
	c) dpms;;
	d) bugs;;
	e) kernel;;
	p) roastyourown;;
	x) clear && byebye;;
esac
main
}

main

byebye

