#!/bin/bash


DISTRONAME=`cat /etc/lsb-release |grep CODENAME |gawk -F= '{ print $2 $3 }'`

ERROR_LOG=/var/log/bbqinstall.log

if [ "$(whoami)" != 'root' ]; then
        TEXT="You have no permission to run bbqinstall as non-root user."
	echo $TEXT
	exit 1;
fi

BBQINSTALL_CONF="/etc/bbqinstall.conf"
EXCLUDES="/etc/bbqinstall_excludes"

usage() {
   echo "$usage_text"
   exit 0
}

usage_text="
Usage:     bbqinstall <disk> <partition>   write GRUB to <disk> and install system to <partition>
Example:   bbqinstall /dev/sda /dev/sda1

Refer to the output of blkid -o list or fdisk -l for file system information.

"

# print file system table
[[ -z $1 ]] && echo "E: Specify disk path and a partition!" && usage
[[ -z $2 ]] && echo "E: Specify a partition!" && usage
[[ ! -e $1 ]] && echo "E: $1 is not a valid drive" && exit 0
[[ ! -e $2 ]] && echo "E: $2 is not a valid partition" && exit 0

# START COUNTING
START=$(date +%s.%N)


cm1=`exec df -P $1 | tail -1 | cut -d' ' -f 1`
cm2=`exec df -P $2 | tail -1 | cut -d' ' -f 1`

echo "I: $1 is mounted per $cm1"
echo "I: $2 is mounted per $cm2"

INSTALL_GRUB="$1"
INSTALL_PART="$2"

# ERROR CHECK
check_exit () {
[[ $? -eq 0 ]] || { echo "

  Exit due to error:  $?
  See $ERROR_LOG for details.
  "
  exit 1 ; }
}


if [[ -f $BBQINSTALL_CONF ]]; then
   echo "I: $BBQINSTALL_CONF found, sourcing"
   source "$BBQINSTALL_CONF"
else
   echo "I: $BBQINSTALL_CONF not found, using defaults" 


### THESE ARE POSSIBLE VALUES THAT ARE NOT IMPLEMENTED YET.
#   ROOT_PASS="root"              
#   HOST="grill"                 
#################################################################

fi
read n
if ! [[ -f $EXCLUDES ]] ; then
cat > "$EXCLUDES" << EOF
- /dev/*
- /cdrom/*
- /media/*
- /target
- /swapfile
- /mnt/*
- /sys/*
- /proc/*
- /tmp/*
- /live
- /lib/live/mount/*
- /boot/grub/grub.cfg
- /boot/grub/menu.lst
- /boot/grub/device.map
- /etc/udev/rules.d/70-persistent-cd.rules
- /etc/udev/rules.d/70-persistent-net.rules
- /etc/fstab
- /etc/mtab
- /home/snapshot
- /home/*/.gvfs
EOF
check_exit
chmod 666 "$EXCLUDES"
fi

if $(df | grep -q /target/proc/) ; then
    umount /target/proc/
fi

if $(df | grep -q /target/dev/) ; then
    umount /target/dev/
fi

if $(df | grep -q /target/sys/) ; then
    umount /target/sys/
fi

mkdir /target

echo "I: Creating file system on $INSTALL_PART"
espeak "Creating file system on $INSTALL_PART" >/dev/null 2>&1


mke2fs -t ext4 "$INSTALL_PART" ; check_exit
tune2fs -r 10000 "$INSTALL_PART" ; check_exit

echo "I: Mounting $INSTALL_PART on target filesystem"
mount $INSTALL_PART /target ; check_exit

echo "I: Copying files to install $DISTRONAME, please wait"

rsync -av / /target/ --exclude-from="$EXCLUDES" >/dev/null 2>&1

echo "I: Adding fstab entries"
echo -e "proc\t\t/proc\tproc\tdefaults\t0\t0
$INSTALL_PART\t/\text4\tdefaults,noatime\t0\t1" >> /target/etc/fstab

echo "I: Mounting target filesystem"
mount --bind /dev/ /target/dev/ ; check_exit
mount --bind /proc/ /target/proc/ ; check_exit
mount --bind /sys/ /target/sys/ ; check_exit

echo "I: Installing bootloader to $INSTALL_GRUB, please wait"

chroot /target grub-install $INSTALL_GRUB > /dev/null 2>&1
chroot /target update-grub > /dev/null 2>&1

echo "I: Removing live user from installation"
chroot /target deluser user
chroot /target rm -rf /home/user

echo "I: Disabling autologin"
chroot /target cp /usr/lib/bbqinstaller/inittab.debian /etc/inittab

#echo "I: Setting terminal capabilities"
#chroot /target setcap 'cap_sys_tty_config+ep' /usr/bin/fbterm

echo "I: Cleaning up"
if $(df | grep -q /target/proc/) ; then
    umount /target/proc/
fi
if $(df | grep -q /target/dev/) ; then
    umount /target/dev/
fi
if $(df | grep -q /target/sys/) ; then
    umount /target/sys/
fi
if $(df | grep -q /target) ; then
    umount -l /target/
fi

END=$(date +%s.%N)
DIFF=$(echo "scale=2; ($END - $START)/1" | bc)
echo "I: Success. Installation finished."
echo  "I: Elapsed time: $DIFF seconds."
echo
echo  "You can now boot into the newly installed system and log in as root using the password root."
echo  "Then, change the root password using the command passwd root."
echo  "Add new users using the command adduser <username>."
