#!/bin/bash
# wrapper for frenchmaid, rempkg, inspkg, get-kernel, kernel-remover, orphaner
. /usr/share/doc/dialog/examples/setup-vars
. /usr/share/doc/dialog/examples/setup-tempfile

if ping -c 1 8.8.8.8 &> /dev/null
then
        echo "Ping ok!"
else
        exit 127
fi

dialog --infobox "Updating, please wait" 0 0

sudo apt update -y &>/dev/null

spkg(){
dialog --clear --title "Package search" --inputbox "Enter the search string" 0 0 term 2> $tempfile

retval=$?
case $retval in
	$DIALOG_CANCEL)
		rm ~/.pkglist* &>/dev/null
		reset
		clear
		selection
esac

dialog --infobox "Searching..." 0 0

apt-cache search `cat $tempfile` > ~/.pkglist

rm $tempfile

ar=()
while read n s ; do
	ar+=($n "$s" "\n")
done < ~/.pkglist

dialog --clear --backtitle "Install Packages"  --checklist "Select packages to install" 0 0 0 "${ar[@]}" 2> $tempfile

retval=$?
case $retval in
	$DIALOG_CANCEL)
		rm ~/.pkglist* &>/dev/null
		reset
		clear
		selection
esac
echo "Installing `cat $tempfile`"
sudo apt install `cat $tempfile`
rm ~/.pkglist* &>/dev/null
}

inspkg()
{
dialog --infobox "Searching..." 0 0

cat /var/lib/apt/lists/*exp*_Packages | grep "Package:" | awk -F ' ' '{ print $2 }' | sort > ~/.pkglist

ar=()
while read n s ; do
	ar+=($n "$s" "\n")
done < ~/.pkglist

dialog --clear --backtitle "Install experimental packages"  --checklist "Select experimental packages to install" 26 45 30 "${ar[@]}" 2> $tempfile
retval=$?
case $retval in
	$DIALOG_CANCEL)
		rm ~/.pkglist &>/dev/null
		reset
		clear
		selection
esac
sudo apt-get -t experimental -y install `cat $tempfile`
rm ~/.pkglist &>/dev/null
}

rempkg(){
dialog --infobox "Please wait..." 0 0

dpkg --get-selections | awk -F ' '  '{ print $1 }' > ~/.pkglist

ar=()
while read n s ; do
	ar+=($n "$s" "\n")
done < ~/.pkglist

dialog --clear --backtitle "Remove Packages"  --checklist "Select packages to remove" 26 45 30 "${ar[@]}" 2> $tempfile
retval=$?
case $retval in
	$DIALOG_CANCEL)
		rm ~/.pkglist* &>/dev/null
		reset
		clear
		selection
esac
sudo apt-get autoremove --purge `cat $tempfile`
rm ~/.pkglist* &>/dev/null
}

rempkgregex()
{
dialog --infobox "Please wait..." 0 0

dpkg --get-selections | awk -F ' '  '{ print $1 }' > ~/.pkglist1

ar=()
while read n s ; do
	ar+=($n "$s" "\n")
done < ~/.pkglist1

dialog --clear --title "Package search" --inputbox "Enter the string to grep all installed packages for" 0 0 term 2> $tempfile
retval=$?
case $retval in
	$DIALOG_CANCEL)
		rm ~/.pkglist* &>/dev/null
		reset
		clear
		selection
esac

grep `cat $tempfile` ~/.pkglist1 > ~/.pkglist2
while read n s ; do
        arr+=($n "$s" "\n")
done < ~/.pkglist2

dialog --clear --backtitle "Remove Packages"  --checklist "Select packages to remove" 26 45 30 "${arr[@]}" 2> $tempfile
retval=$?
case $retval in
	$DIALOG_CANCEL)
		rm ~/.pkglist* &>/dev/null
		reset
		clear
		selection
esac
sudo apt-get autoremove --purge `cat $tempfile`
rm ~/.pkglist* &>/dev/null
}

selection(){
dialog --title "BBQ Package Management" --menu "Please select an action. Keep your password ready!" 0 0 0 \
"upgrade" "Upgrade the system" \
"spkg" "Search and install packages" \
"inspkg" "Install packages from experimental" \
"rempkg" "Remove packages quickly" \
"rempkgregex" "Search and remove packages" \
"get-kernel" "Install kernels" \
"kernel-remover" "Remove unused kernels" \
"frenchmaid" "Clean up log files and backups" \
"orphaner" "Remove orphaned packages" \
"Exit" "Exit BBQPKG" 2> $tempfile

retval=$?
case $retval in
	$DIALOG_CANCEL)
		exit 0;;
esac
menu=$(<"$tempfile")
case $menu in
 "spkg") spkg ;;
 "upgrade") sudo apt dist-upgrade;;
 "frenchmaid") frenchmaid;;
 "rempkg") rempkg;;
 "rempkgregex") rempkgregex;;
 "inspkg") inspkg;;
 "get-kernel") get-kernel;;
 "kernel-remover") sudo kernel-remover;;
 "orphaner") sudo orphaner --purge;;
 "Exit") exit 0;;
esac
}
selection
