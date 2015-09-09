#!/bin/bash

# system2iso
# create an ISO from the running sytem
#
# part of the sys2iso framework (system2iso, system2iso_chroot, system2iso_remix)
#
# written by Julius Hader <bacon@linuxbbq.org>, October 2013
# based on articles of qualitri and askubuntu
#
# TODO:
# - change up-to-down to functions
#	- then convert to dialog/whiptail
#	- rewrite installer routine of bbqinstaller
#	- create sys2iso main wrapper for framework
# - add interactive mode for chroot session
#	- interactive customization of environment variables (not a good idea)
#
# If you have ddeas and suggestions please mail to <bacon@linuxbbq.org>
#
################################################################################

# Set color environment
# Check if user is root
# Set environment variables
# Print introduction and warning
# Check for existing snapshot
# rsync and copy files to work folder
# move to chroot and bail out

# Set color environment

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

# Check if luser is root
if [[ $EUID -ne 0 ]]; then
	cecho "	Are you root?" $red 2>&1
	echo 
	cecho "	Solution:" $green
	echo  "	run 'sudo system2iso'"
	echo
	exit 1
fi

# Set environment vars
export WORK=/sys2iso/work
export CD=/sys2iso/cd
export FORMAT=squashfs
export FS_DIR=casper

# Print introduction
clear

cecho "Welcome to system2iso." $cyan 
echo
echo "If run for the first time, this script will create two directories, "
echo "namely ${CD} and ${WORK} in the root directory. It will copy the running system and create"
echo "a redistributable ISO from it."
echo
echo "The script is set up in three parts:"
echo " - system2iso (which you are running now)"
echo " - system2iso_chroot (which will run operations after switching to chroot)"
echo " - system2iso_last (which will create the actual ISO from a copied file system)"
echo
echo "If you have previously created a copy of the filesystem with the system2iso script, you can"
echo "find it in ${WORK} and manipulate it - eg. add scripts, change configurations - and then run"
echo "the system2iso_last script. However, if you wish to add .deb packages to an existing copy of"
echo "the filesystem, please remove ${WORK} and start again."
echo
cecho "Before you continue, make sure that:" $red
echo "        - you have removed personal data from your /home/$USER directory
	- you have created an /etc/skel directory for new users
	- you have enough space (actual filesystem times 3) on your drive
	- you have cleared the cache of APT (/var/lib/apt/list files) to save space on the destination system"
echo
if [ -d "${WORK}" ]; then
	cecho "I found a ${WORK} directory. If you continue, its content will be overwritten." $red
else
	cecho "There is no ${WORK} directory. We can continue if you wish so." $green
fi
echo
echo "Press a key to continue or Ctrl-c to exit here."

read

## Check if there is a work folder

if [ -d "${WORK}" ]; then
	cecho "Skipping creation of ${WORK} and ${CD}..." $green
else
	cecho "Creating ${CD} and ${WORK}..." $cyan
	mkdir -p ${CD}/${FS_DIR}
	mkdir -p ${CD}/boot/grub
	mkdir -p ${WORK}/rootfs
fi
echo

## Count files and copy them

cecho "Fetching number of files... takes a few seconds." $cyan
FILENUM=$(find / | sort | uniq | wc -l)
echo
cecho "Found ${FILENUM} files, copying to ${WORK}" $cyan
echo
rsync -a --progress --one-file-system --exclude=/proc/* --exclude=/dev/* \
    --exclude=/sys/* --exclude=/tmp/* --exclude=/lost+found \
    --exclude=/var/tmp/* --exclude=/boot/grub/* --exclude=/root/* \
    --exclude=/var/mail/* --exclude=/var/spool/* --exclude=/media/* \
    --exclude=/etc/fstab --exclude=/etc/mtab --exclude=/etc/hosts \
    --exclude=/etc/timezone --exclude=/etc/shadow* --exclude=/etc/gshadow* \
    --exclude=/etc/X11/xorg.conf* --exclude=/mnt/* --exclude=${CD} --exclude=${WORK}/rootfs / ${WORK}/rootfs | pv -l -e -p -s ${FILENUM} -i 0.1 > /dev/null
echo
cp /run/resolv.conf ${WORK}/rootfs/etc/
cecho "Copying boot directory..." $cyan
cp -av /boot/* ${WORK}/rootfs/boot | pv -l -e -p -s ${FILENUM} -i 0.1 > /dev/null

## Mount for chroot

sudo mount --bind /dev/ ${WORK}/rootfs/dev
sudo mount -t proc proc ${WORK}/rootfs/proc
sudo mount -t sysfs sysfs ${WORK}/rootfs/sys

cecho "Chrooting into the copied filesystem. Please run system2iso_chroot now!" $cyan

## Sayonara

sudo chroot ${WORK}/rootfs /bin/bash
