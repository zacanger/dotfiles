#!/bin/bash

# system2iso_chroot (part of sys2iso)

# SHOULD NOT BE RUN STAND-ALONE!


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


# check if user is root
if [[ $EUID -ne 0 ]]; then
	cecho "Are you root?" $red 2>&1
	echo 
	cecho "Solution: run 'sudo system2iso_chroot'" $green
	exit 1
fi

# check if we are in chroot

if [ "$(awk '$5=="/" {print $1}' </proc/1/mountinfo)" != "$(awk '$5=="/" {print $1}' </proc/$$/mountinfo)" ]; then
	cecho "Welcome to system2iso_chroot...!" $green
else
	cecho "Don't even try to run it outside of chroot, sorry!" $red
	echo
	cecho "Solution: run 'system2iso' first." $green
	echo
	exit 1
fi

# if yes, change the prompt in case we ejaculate prematurely
export PS1="(chroot) "

# set up environment once more
export WORK=~/work
export CD=~/cd
export FORMAT=squashfs
export FS_DIR=casper

cecho "Resetting language variable..." $cyan

LANG=
echo
cecho "Updating initramfs..." $cyan

depmod -a $(uname -r)
update-initramfs -u -k $(uname -r)

echo
cecho "Cleaning up..." $cyan

# This section is removed - maybe forever. We don't want a stinky Live user without password
# and tons of error messages when folders are not chowned.
#
#echo "    - users"
#
#for i in `cat /etc/passwd | awk -F":" '{print $1}'`
#do
#    uid=`cat /etc/passwd | grep "^${i}:" | awk -F":" '{print $3}'`
#    [ "$uid" -gt "998" -a "$uid" -ne "65534" ] && userdel --force ${i} 2>/dev/null
#done

cecho "    - apt-cache" $yellow

apt-get clean

# We keep these because the installer will allow us to pick a hostname.
#
#echo "    - DNS"
#
#rm /etc/resolv.conf /etc/hostname

cecho "    - logfiles" $yellow

find /var/log -regex '.*?[0-9].*?' -exec rm -v {} \;
find /var/log -type f | while read file
do
    cat /dev/null | tee $file
done

cecho "Exiting chroot..." $cyan
echo

cecho "The chroot environment has been set up. To create an ISO from it, type 'exit' and 'system2iso_last' as next!" $cyan
