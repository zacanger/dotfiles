#!/bin/sh
#
# chooser
#
#	Lists essids from iwlist and prompts user to select one,
#	rescan, or manually input an ssid.  Then it prompts the user
#	whether to run the DHCP client daemon.
#
# http://qaa.ath.cx/chooser
#
# (c) Copyright 2005-2008, Christopher J. McKenzie under
# the terms of the GNU Public License, incorporated
# herein by reference.
#
# --- HISTORY ---
#	080718 Channel wasn't being parsed right - cjm
#	071109 Signal/Encryption details printed - cjm
#	070630 + /sbin added to path for Fedora - cjm
#	       ~ option -> IPoption for DHCP - cjm
#	060328 A few bugs fixed - cjm
#	060326 Various things - cjm
#	060324 Fedora Core Support - Ivan M. Font
#
# Thanks to the following who have 
# tested/used/told me/corrected what was wrong
#	Del Daniels
#	Ivan Font
#	Loris Degioanni
NAME="Chooser"
VERSION=1.1.1294
AUTHOR="Christopher McKenzie and others"
WEBSITE="http://qaa.ath.cx/chooser"
INTERACTIVE=1

while [ $# -gt 0 ]; do
	if [ $1 == "--version" ]; then
		echo $NAME version $VERSION
		echo " "By $AUTHOR
		echo " "Get the latest version at $WEBSITE
		exit
	elif [ $1 == "--usage" ]; then
		echo $Name
		echo " --quick Non-interactive mode.  Can be used with watch(1)."
	elif [ $1 == "--quick" ]; then
		INTERACTIVE=0
	fi
	shift
done
# probe for interface in use
# Ok, here is the logic,  In iwconfig some line will have "IEEE 802.11" - that will be wlan...duh's

PATH=$PATH:/sbin/
export PATH

interface=`iwconfig 2> /dev/null | grep IEEE\ 802.11 | awk ' { print $1 } '`

if [ ! -n "$interface" ]; then
	echo Unable to find a suitable interface. Exiting!
	exit
fi

# I know that iwpriv is required for the hostap drivers	- maybe more?!
useiwpriv=`lsmod | grep hostap | wc -l`

# What dhcp?
dhcpclient=/sbin/dhclient	#default to something
[ -f /sbin/dhcpcd ] && dhcpclient=/sbin/dhcpcd #fall back on this if exist

# Checks user ID
if [ ! "$UID" = "0" ]; then
	echo You probably need to be root.  Type 1 to continue anyway, any other key to exit.
	read option
	[ "$option" = "1" ] || exit
fi

# Kills DHCP client daemon
pkill $dhcpclient

# Brings the wlan interface up (needed for scanning).
ifconfig $interface up

# Various things needed
[ "$useiwpriv" -gt "0" ] && iwpriv $interface host_roaming 2
iwconfig $interface mode managed
iwconfig $interface essid any

# A dhcp client prompt
dhcp() {
	echo "1 DHCP"
	echo "2 Manual Entry"
	echo "3 Exit"
	echo -n ">> "

	read IPoption

	case $IPoption in
		1)
			echo "Running DHCP client on $interface" && $dhcpclient $interface
			;;
		2)
			echo Your desired IP address
			read ip
			ifconfig $interface $ip && echo Set IP Address to $ip || echo Failed to set address of $interface
			echo Gateway IP address
			read ip
			route del default && echo Deleted default route || echo Failed to delete default route
			route add default gw $ip && echo Set Default route to $ip || echo Failed to set default route
			;;
	esac

	loop=0
}

# The main scanning function
scan() {
# iwlist and parse
	[ "`iwlist $interface scan 2> /dev/stdout | wc -l`" -eq "2" ] && echo Oops, Error! Go to http://qaa.ath.cx/, send an email to Chris Mckenzie. && exit -1
	filename=`echo /tmp/chooser.$PPID.tmp`
	iwlist $interface scan > $filename
	ADDRESS=( `cat $filename | grep Address: | gawk -F - '{ printf("%s ",$2) }' | sed s/Address://g` )
	ESSID=( `cat $filename | grep ESSID | gawk -F \" '{ printf("%s@",$2) }' | sed s/\"//g | sed s/\ /\./g | sed s/\@/\ /g ` )
	SIGNAL=( `cat $filename | grep Signal\ level | gawk '{ printf("%s ",$3) }' | sed s/'\/'100//g | sed s/level.//g` )
	CHANNEL=( `cat $filename | grep Channel | gawk -F \( '{ printf("%s ",$2) }' | sed s/Channel\ //g | sed s/\)//g`  )
	if (( ${#CHANNEL[@]} == 0 )); then
		CHANNEL=( `cat $filename | grep Channel | gawk -F \: '{ printf("%s ",$2) }'` )
	fi
	ENCRYPTION=( `cat $filename | grep Encryption\ key: | gawk -F : '{ printf("%s ",$2) }'`  )
# The default options
# Print out the SSID's found
	printf "DEVICE: %-10s CHANNEL       ENCRYPTION\n" $interface
	echo "  |   MAC ADDRESS   |   |  SIGNAL  |    |       ESSID"
	echo --+-----------------+---+----------+----+--------------------

	for (( i = 0 ; i < ${#ESSID[@]} ; i++ ))
	do
		smaller=$(( ${SIGNAL[$i]} / 10 ))
		case $smaller in
			1)
				status="|#.........|"
				;;
			2)
				status="|##........|"
				;;
			3)
				status="|###.......|"
				;;
			4)
				status="|####......|"
				;;
			5)
				status="|#####.....|"
				;;
			6)
				status="|######....|"
				;;
			7)
				status="|#######...|"
				;;
			8)
				status="|########..|"
				;;
			9)
				status="|#########.|"
				;;
			10)
				status="|##########|"
				;;
			*)
				status="|..........|"
				;;
		esac
	
		choice=$(( i + 1 ))
		printf "%-2s|%s|%-2s %-12s%-4s|%s\n" $choice ${ADDRESS[$i]} ${CHANNEL[$i]} $status ${ENCRYPTION[$i]} ${ESSID[$i]}
	done
	if (( $INTERACTIVE == 1 )); then
		echo "[R] Rescan   [M] Manual Entry   [E] Exit"
		echo -n ">> "
		read option
		# If the user wants to manually type it in
		case "$option" in
			[eE])
				loop=0
				;;
			[mM])
				[ "$useiwpriv" -gt "0" ] && iwpriv $interface host_roaming 0 
				echo "Type the SSID you want to connect to"
				read essid
				iwconfig $interface essid "$essid"
				dhcp
				;;
			[1-9]*)
				[ "$useiwpriv" -gt "0" ] && iwpriv $interface host_roaming 0 
				option=$(( option - 1 ))
				echo "Associating with "${ESSID[$option]} @ ${ADDRESS[$option]}
				iwconfig $interface ap ${ADDRESS[$option]}
				dhcp
				;;
			*)
				loop=1
				;;
		esac
	else
		# exit after printing
		loop=0
	fi	
}

loop=1
scan
# Loop while the "rescan" option is selected
while (( $loop == 1 )) ; do
	echo
	echo =============================================================
	loop=0;
	scan
done
