#!/bin/bash
sudo -v
echo "These partitions exist :"
sudo blkid -o list
echo
echo "These directories exist in /mnt :"
ls -a /mnt

fstab-build()
{
	echo "# from device /dev/sda:"
	sudo mount | awk '/^\/dev\/sda/ {print $1,"\t",$3,"\t",$5,"\tdefaults\t0","\t0"}'
	echo "# from device /dev/sdb:"
	sudo mount | awk '/^\/dev\/sdb/ {print $1,"\t",$3,"\t",$5,"\tdefaults\t0","\t0"}'
	echo "# from device /dev/sdc:"
	sudo mount | awk '/^\/dev\/sdc/ {print $1,"\t",$3,"\t",$5,"\tdefaults\t0","\t0"}'
}

mounter()
{
	echo
	echo "Enter Mountpoint name (eg. part1) :"
	read n
	echo "Device node (eg. /dev/sda4) : "
	read m
	sudo mkdir -p /mnt/$n
	sudo mount $m /mnt/$n
	echo "The mountpoints are as follows :"
	echo "-----------------------------------------------------------------"
	fstab-build
	echo "-----------------------------------------------------------------"
}
mounter
echo
read -n1 -p "More? (y/n) "
if [ $REPLY = 'y' ]; then
	mounter
fi
echo
echo "You can copy this snippet and paste it into your /etc/fstab file:"
echo
echo "# start: manually added partitions"
fstab-build
echo "# end: manually added partitions"
echo


