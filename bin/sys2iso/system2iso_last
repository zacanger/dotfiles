#!/bin/bash

######################################### 
black='\E[30;40m'
red='\E[31;40m'
green='\E[32;40m'
yellow='\E[33;40m'
blue='\E[34;40m'
magenta='\E[35;40m'
cyan='\E[36;40m'
white='\E[37;40m'
Reset="tput sgr0"
cecho (){
	local default_msg={}
	message=${1:-$default_msg}
	color=${2:-black}
	echo -e "$color"
	echo "$message"
	$Reset
	return
}
#########################################


if [[ $EUID -ne 0 ]]; then
	cecho "Are you root?" $red 2>&1
	echo 
	cecho "Solution: run 'sudo system2iso_last'" $green
	echo
	exit 1
fi

export ISODIR=/sys2iso
export WORK=/sys2iso/work
export ROOTFS=/sys2iso/work/rootfs
export CD=/sys2iso/cd
export FORMAT=squashfs
export FS_DIR=casper
export ISONAME="linuxbbq"

echo "A bootable ISO file will be created from the content of ${WORK}"
cecho "Hit a key to continue or press Ctrl-c to abort." $red
read

cecho "Copying the kernel..." $cyan
export kversion=`cd ${WORK}/rootfs/boot && ls -1 vmlinuz-* | tail -1 | sed 's@vmlinuz-@@'`
sudo cp -vp ${WORK}/rootfs/boot/vmlinuz-${kversion} ${CD}/${FS_DIR}/vmlinuz
echo
cecho "Copying the initrd..." $cyan
sudo cp -vp ${WORK}/rootfs/boot/initrd.img-${kversion} ${CD}/${FS_DIR}/initrd.img
echo
cecho "Copying memtest..." $cyan
sudo cp -vp ${WORK}/rootfs/boot/memtest86+.bin ${CD}/boot
echo
cecho "Create a manifest for Ubiquity - not needed, but we do it anyway... ignore errors!" $yellow
sudo chroot ${WORK}/rootfs dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee ${CD}/${FS_DIR}/filesystem.manifest
sudo cp -v ${CD}/${FS_DIR}/filesystem.manifest{,-desktop}
REMOVE='ubiquity casper user-setup os-prober libdebian-installer4'
for i in $REMOVE
do
    sudo sed -i "/${i}/d" ${CD}/${FS_DIR}/filesystem.manifest-desktop
done
echo
cecho "Unmounting proc, sys and dev... ignore errors!" $yellow
sudo umount ${ROOTFS}/proc
sudo umount ${ROOTFS}/sys
sudo umount ${ROOTFS}/dev

# let user change the distro-defaults
system2iso_distro-defaults

cecho "Creating a squashfs... This might take a few minutes" $cyan

mksquashfs ${ROOTFS} ${CD}/${FS_DIR}/filesystem.${FORMAT} -noappend

cecho "Creating filesystem.size... ignore errors!" $yellow

echo -n $(du -s --block-size=1 ${ROOTFS} | tail -1 | awk '{print $1}') | tee ${CD}/${FS_DIR}/filesystem.size > /dev/null

cecho "Calculating MD5..." $cyan

find ${CD} -type f -print0 | xargs -0 md5sum | sed "s@${CD}@.@" | grep -v md5sum.txt | sudo tee -a ${CD}/md5sum.txt

mkdir ${CD}/boot/grub
cp /usr/local/share/grub.cfg ${CD}/boot/grub/grub.cfg

cecho "Opening editor, press a key to continue..." $yellow

nano ${CD}/boot/grub/grub.cfg

cecho "Enter a name for the ISO, without extension, without special characters and whitespaces" $cyan
read ISONAME
echo
cecho "Creating the ISO..." $cyan
sudo mkdir /sys2iso/
sudo grub-mkrescue -o ${ISODIR}/${ISONAME}.iso ${CD}

du ${ISODIR}/${ISONAME}.iso

cecho "Finished. The ISO named ${ISONAME}.iso can be found in the ${CD} directory." $green

echo

cecho "To create a bootable USB stick, do the following:" $cyan
echo
echo "	1. Plug in your USB stick now"
echo "  2. Enter 'sudo fdisk -l'  and find the device node, eg. /dev/sdc"
echo "  3. Issue 'sudo dd if=${CD}/${ISONAME}.iso of=/dev/sdc'"
echo "     where sdc is the actual location of your USB stick."
echo
cecho "Thank you for using system2iso, have fun with your remix!" $cyan
echo
exit 0
