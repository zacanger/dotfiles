#!/bin/bash

# The BBQ CLI Menu
# May-July 2013 <bacon@linuxbbq.org>
# this time only depending on dialog

# set fancy colors
# using .dialogrc

# set var
INPUT=/tmp/menu.sh.$$

# set function for upgrade warning
function upgrade(){
	wget http://linuxbbq.org/feed_format.txt -O /tmp/feed_format.txt
	dialog --backtitle "LinuxBBQ - Bork Your Own" --title "Upgrade warnings" --textbox /tmp/feed_format.txt 0 0
	rm /tmp/feed_format.txt
}

# bbq system hospital
function bbqfix(){
dialog --backtitle "LinuxBBQ - Start" --title "System Hospital" --menu " \n" 0 0 0 \
	a "Set Timezone" \
	k "Set keymap" \
	l "Set localization" \
	b "Sync Network Time" \
	c "Reset and fix soundcard" \
	C "Fix Maestro and ESS soundcards" \
	d "Edit sources.list" \
	e "Update GRUB2" \
	f "Repair GRUB" \
	g "Remove unused kernels" \
	h "Install CUPS" \
	i "Reconfigure all packages through dpkg" \
	j "Update application alternatives" \
	m "Configure and check network" \
	n "Edit HOSTS file" \
	o "Add adblocking to HOSTS file" \
	p "Run testdisk to repair hard drives" \
	q "Install Asian Language support" \
	r "Install nVidia drivers" \
	s "Edit Sources List" \
	t "Edit GRUB file" \
	u "Change Distro Defaults" \
	v "Install localepurge and remove unused locales" \
	w "Remove orphaned packages" \
	b "Back to Main" \
	x "Exit BBQ Menu" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	w) sudo orphaner;;
	v) sudo apt-get install localepurge && sudo localepurge;;
	h) bbqcups;;
	i) sudo dpkg-reconfigure --all;;
	j) sudo update-alternatives --all;;
	k) sudo dpkg-reconfigure keyboard-configuration;;
	l) sudo dpkg-reconfigure locales;;
	m) sudo service networking restart && service network-manager restart;;
	n) sudo mcedit /etc/hosts;;
	o) sudo adblock-host;;
	p) sudo testdisk;;
	q) bbqasian;;
	r) sudo bbqnvidia;;
	s) sudo mcedit /etc/apt/sources.list.d/bbq.list;; 
	t) sudo mcedit /etc/default/grub;;
	u) sudo bbq-distro-defaults;;
	a) sudo dpkg-reconfigure tzdata;;
	b) sudo ntpdate 0.nl.pool.ntp.org;;
	c) fixsnd;;
	C) fixess;;
	d) sudo mcedit /etc/apt/sources.list.d/bbq.list;;
	e) sudo update-grub;;
	f) sudo grubrepair;;
	g) sudo kernel-remover -F text;;
	b) main;;
	x) exit 0;;
esac
main
}

# set function for the office menu
function office(){
dialog --backtitle "LinuxBBQ - Start" --title "Office" --menu " \n" 18 30 12 \
	W "Word Processor" \
	S "Spreadsheet" \
	E "Email Client" \
	N "Newsreader" \
	a "Address Book" \
	d "Calendar" \
	c "Calculator" \
	t "To Do" \
	p "Personal Information Manager" \
	b "Back to Main" \
	x "Exit BBQ Menu" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	W) wordgrinder;;
	S) sc;;
	E) mutt;;
	N) newsbeuter;;
	A) alsamixer;;
	r) bbqradio;;
	m) mocp -T slob;;
	T) tv;;
	l) shell-fm;;
	a) abook;;
	c) bc;;
	t) calcurse;;
	p) tina;;
	d) wyrd;;
	b) main;;
	x) exit 0;;
esac
}
	
# media menu
function media(){
dialog --backtitle "LinuxBBQ - Start" --title "Multimedia" --menu " \n" 14 30 10 \
	A "Alsamixer" \
	r "Radio" \
	m "Music Player" \
	T "TV Player" \
	l "Shell.fm" \
	b "Back to Main" \
	x "Exit BBQ Menu" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	A) alsamixer;;
	r) bbqradio;;
	m) mocp -T slob;;
	T) tv;;
	l) shell-fm;;
	b) main;;
	x) exit 0;;
esac
}

# Network Menu
function network(){
dialog --backtitle "LinuxBBQ - Start" --title "Network" --menu " \n" 14 30 10 \
	l "Links2 Browser" \
	i "IRC Client" \
	c "Instant Messenger" \
	e "Mutt Mail Client" \
	n "Newsreader" \
	b "Back to Main" \
	x "Exit BBQ Menu" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	l) links2 www.startpage.com ;;
	i) irssi;;
	c) centerim;;
	e) mutt;;
	n) newsbeuter;;
	b) main;;
	x) exit 0;;
esac
}

# accessories
function acc(){
dialog --backtitle "LinuxBBQ - Start" --title "Accessories" --menu " \n" 14 30 10 \
	m "Midnight Commander" \
	r "Ranger" \
	v "mcedit" \
	h "htop Process Monitor"\
	d "Disk Usage" \
	b "Back to Main" \
	x "Exit BBQ Menu" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	m) mc;;
	r) ranger;;
	v) mcedit;;
	h) htop;;
	d) ncdu;;
	b) main;;
	x) exit 0;;
esac
}

# games
function games(){
dialog --backtitle "LinuxBBQ - Start" --title "Games" --menu " \n" 14 30 10 \
	a "bastet" \
	b "rogue" \
	c "ninvaders" \
	d "freesweep"\
	e "pacman" \
	f "adventure" \
	g "phantasia" \
	h "worm" \
	i "cribbage" \
	j "snake" \
	k "wargames" \
	l "sail" \
	m "robots" \
	n monop \
	o boggle \
	p hangman \
	q hack \
	r backgammon \
	s mille \
	t canfield \
	u wump \
	v tetris \
	w gomoku \
	y trek \
	z battlestar \
	B "Back to Main" \
	x "Exit BBQ Menu" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	a) bastet;;
	b) rogue;;
	c) ninvaders;;
	d) freesweep;;
	e) pacman;;
	f) adventure;;
	g) phantasia;;
	h) worm;;
	i) cribbage;;
	j) snake;;
	k) wargames;;
	l) sail;;
	m) robots;;
	n) monop;;
	o) boggle;;
	p) hangman;;
	q) hack;;
	r) backgammon;;
	s) mille;;
	t) canfield;;
	u) wump;;
	v) tetris;;
	w) gomoku;;
	y) trek;;
	z) battlestar;;
	B) main;;
	x) exit 0;;
esac
}

# main selection
function main(){
dialog --backtitle "LinuxBBQ - Start" --title "Main Menu" --menu " \n" 18 30 16 \
	f "Fix your system" \
	u "Upgrade Warnings" \
	a "Accessories" \
	n "Network and Chat" \
	o "Office" \
	m "Multimedia" \
	g "Games" \
	b "Reboot" \
	q "Power off" \
	x "Exit BBQ Menu" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	f) bbqfix;;
	u) upgrade ;;
	a) acc ;;
	n) network;;
	o) office;;
	m) media;;
	g) games;;
	b) sudo /sbin/reboot;;
	q) sudo /sbin/poweroff;;
	x) exit 0;;
esac
}

main

exit 0
