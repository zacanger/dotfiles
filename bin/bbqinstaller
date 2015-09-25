#!/usr/bin/env bash
version="bbqinstaller 9.0.5-3 (20120805)"
# Copyright 2011 fsmithred@gmail.com
# Based on bbqinstaller-8.0.3 by Dean Linkous
# Licence: GPL-3
# This is free software with no warrantees. Use at your own risk.

# This script will install a bbq live-cd to a hard drive. It gives
# you the option to install the entire system to one partition or to
# install with /home on a separate partition. 

# NOTE: If you try to tee this to an install log, you won't see it
# when cryptsetup asks you to confirm with YES.



# If you want to change any defaults, change them in the configfile.
# Default is /etc/bbqinstaller.conf
# If you want to use a different config file for testing, change this
# variable. Normally, users should not edit anything in this script.
configfile="/etc/bbqinstaller.conf"
INPUT=/tmp/menu.sh.$$

show_help () {
	printf "$help_text"
	exit 0
}

help_text="
	Usage:  $0  [option]
	
	Run with no options to install a running live-CD or live-usb-hdd
	to a hard drive. 
	
	If you want to use the graphical version, run bbqinstaller-gui
	from a terminal or run bbq Installer from the System menu.
	
	valid options:
		-h, --help		show this help text
		-v, --version	display the version information

"

while [[ $1 == -* ]]; do
	case "$1" in
	
		-h|--help)
			show_help ;;
		
		-v|--version)
			printf "\n$version\n\n" 
			exit 0 ;;
		
		*) 
			printf "\t invalid option: $1 \n\n"
			printf "\t Try:  $0 -h for full help. \n\n"
			exit 1 ;;
    esac
done		


# Check that user is root.
[[ $(id -u) -eq 0 ]] || { echo -e "\t You need to be root!\n" ; exit 1 ; }

dialog --clear --backtitle "LinuxBBQ Installer" --msgbox "\n    Welcome to LinuxBBQ  \n    Hit Enter to start...\n" 8 32;


bbqinstaller_configuration () {
if [[ -f $configfile ]]; then
    source $configfile
else
	echo "
	Information: Config file $configfile is missing
	Proceeding with default settings...
"
fi
# Check for values in $configfile and use them.
# If any are unset, these defaults will be used.
error_log=${error_log:="/var/log/bbqinstaller_error.log"}
rsync_excludes=${rsync_excludes:="/usr/lib/bbqinstaller/installer_exclude.list"}
home_boot_excludes=${home_boot_excludes:="/usr/lib/bbqinstaller/home_boot_exclude.list"}
swapfile_blocksize=${swapfile_blocksize:="1MB"}
swapfile_count=${swapfile_count:="256"}
pmount_fixed=${pmount_fixed:="no"}
enable_updatedb=${enable_updatedb:="yes"}
enable_freshclam=${enable_freshclam:="yes"}
root_ssh=${root_ssh:="no"}
}

bbqinstaller_configuration



# Record errors in a logfile.
exec 2>"$error_log"


# function to exit the script if there are errors
check_exit () {
[[ $? -eq 0 ]] || { echo "
  
  Exit due to error:  $?
  See $error_log for details.
  "
  exit 1 ; }
}




# Check that rsync excludes file exists, or create one.
if ! [[ -f  $rsync_excludes ]] ; then
    echo "
 There is no rsync excludes file, or its name does not match what
 this script expects. You should let the script create one, or if
 you have a custom excludes file, and you know what you're doing,
 you can exit the script and edit the rsync_excludes variable at 
 the top so that it matches the name and path of your custom file.

 Press ENTER to proceed or hit ctrl-c to exit. "
    read -p " "
    rsync_excludes="$(pwd)/installer_exclude.list"
    echo " Creating rsync excludes file, $rsync_excludes
 "
    sleep 2
    cat > "$rsync_excludes" <<EOF
# It is safe to delete this file after installation.

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
chmod 666 "$rsync_excludes"
fi 



# Partition a disk
dialog --backtitle "LinuxBBQ Installer" --title "Prepare Partition" --menu "You need to have a partition ready for the installation. If you haven't already done that, you can run the partition editor now. If you want a separate home partition, you should create it at this time, this script will ask you later if you've done that." 20 60 15 \
     g parted \
     c cfdisk \
     n "I already have a partition prepared. Continue." \
     q "Exit the script now." 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
      g) parted ;;
      c) cfdisk ;;
      n) ;;
      q) exit 0 ;;
esac



# Ask to display partitions

dialog --backtitle "LinuxBBQ Installer" --yesno "Would you like fdisk to show you what drives and partitions are available?" 7 55
if [ "$?" != "0" ]; then
	dialog --clear
else
	dialog --backtitle "LinuxBBQ Installer" --title "Partitions" --infobox " " 5 35
	sudo fdisk -l >> /tmp/disk.txt
	dialog --textbox /tmp/disk.txt 0 0
	rm /tmp/disk.txt
fi

# Leave these variables blank. You will be asked to provide values.
grub_dev=
boot_dev=
fs_type_boot=
install_dev=
fs_type_os=
home_dev=
fs_type_home=
use_uuid=


# Select location for bootloader.
# If location is entered but does not exist, then exit with error.

dialog --backtitle "LinuxBBQ Installer" --title "GRUB" --inputbox "

 Where would you like the GRUB bootloader to be installed?
 (probably a drive, like /dev/sda) 
 
 If you do not want to install the bootloader, leave this blank:" 0 0 2>"${INPUT}"
 
grub_dev=$(<"${INPUT}")

if [[ -n $grub_dev ]] ; then
    [[ -b $grub_dev ]] || { echo "$grub_dev does not exist!" ; exit 1 ; }
fi


# Enter device for /boot partition or skip. If one is entered, test it.
dialog --backtitle "LinuxBBQ Installer" --title "Boot Partition" --inputbox "

If you created a separate partition for /boot, enter it here.
To skip this, just hit the ENTER key.
 
 (give the full device name, like /dev/sda1): " 0 0 2>"${INPUT}"
 
boot_dev=$(<"${INPUT}")
 
echo "$boot_dev"
if ! [[ -z $boot_dev ]] && ! [[ -b $boot_dev ]] ; then
    dialog --backtitle "LinuxBBQ Installer" --title "Boot Partition" --msgbox " $boot_dev does not exist! \n
You may continue and install without a separate boot partition, or you can hit ctrl-c to exit, then re-run the script, and  be sure to create a partition for /boot." 0 0
    boot_dev=
fi


# Choose filesystem type for /boot if it exists.
if [[ -n $boot_dev ]] ; then
    dialog --backtitle "LinuxBBQ Installer" --title "Prepare Partition" --menu " What type of filesystem would you like on $boot_dev? " 20 60 15 \
    2 "ext2 (recommended for /boot)" \
    3 "ext3" \
    4 "ext4"  2>"${INPUT}"
  menuitem=$(<"${INPUT}")
  case $menuitem in
          2) fs_type_boot="ext2" ;;
          3) fs_type_boot="ext3" ;;
          4) fs_type_boot="ext4" ;;
  esac
fi


# Choose partition for root filesystem
dialog --backtitle "LinuxBBQ Installer" --title "Partition for Installation" --inputbox "

 Which partition would you like to use for the installation of the operating system?
 
 (give the full device name, like /dev/sda1): " 0 0 2>"${INPUT}"
 
install_dev=$(<"${INPUT}")
[[ -b $install_dev ]] || { echo "$install_dev does not exist!" ; exit 1 ; }

# Choose filesystem type for OS.
dialog --backtitle "LinuxBBQ Installer" --title "Prepare Partition" --menu " What type of filesystem would you like on $install_dev? " 20 60 15 \
    2 "ext2" \
    3 "ext3" \
    4 "ext4"  2>"${INPUT}"
  menuitem=$(<"${INPUT}")
case $menuitem in
          2) fs_type_os="ext2" ;;
          3) fs_type_os="ext3" ;;
          4) fs_type_os="ext4" ;;
esac



# Decide if OS should be encrypted
dialog --backtitle "LinuxBBQ Installer" --defaultno --yesno "Do you want the operating system on an encrypted partition?" 7 55
if [ "$?" != "0" ]; then
	encrypt_os="no"
	dialog --clear
else
 encrypt_os="yes"
             # test for cryptsetup
             if ! [[ -f /sbin/cryptsetup ]]; then
                     dialog --backtitle "LinuxBBQ Installer" --yesno "Cryptsetup is not installed. You need to  install it and run the command, 'sudo modprobe dm-mod' before you can use encryption.Do you want to proceed without encrypting the partition?\n" 0 0
                    if [ "$?" != "0" ]; then
						exit 1 
					else
                       encrypt_os="no" 
                    fi
             fi
             # end test for cryptsetup
             #
             # test to make sure there's a separate /boot partition
             if [[ -z $boot_dev ]] ; then
                     dialog --backtitle "LinuxBBQ Installer" --yesno  "You MUST have a separate, unencrypted /boot partition if you intend to boot an encrypted operating system. You can proceed without encrypting the root filesystem, or you can exit and start over. Do you want to proceed without encrypting the partition?\n" 0 0
                    if [ "$?" != "0" ]; then
						exit 1 
					else
                    dialog --clear
                    fi
            fi
            # end test for separate /boot partition
fi
# Enter device for /home partition or skip. If one is entered, test it.
dialog --backtitle "LinuxBBQ Installer" --title "Separate Home" --inputbox "


If you created a separate partition for /home, enter the full device name. However, if you're installing everything to one partition, you should leave this blank.

/home partition (if one exists): " 0 0 2>"${INPUT}"
 
home_dev=$(<"${INPUT}")
if [[ -n $home_dev ]] && ! [[ -b $home_dev ]] ; then
    dialog --backtitle "LinuxBBQ Installer" --title "Home Partition" --msgbox "$home_dev does not exist! \n

    You may continue and install everything to one partition, or you can hit ctrl-c to exit, then re-run the script, and be sure to create a partition for /home." 0 0
    home_dev=
fi

# Choose filesystem type for /home if needed
if [[ -n $home_dev ]] ; then
   dialog --backtitle "LinuxBBQ Installer" --title "Prepare Partition" --menu " What type of filesystem would you like on $home_dev? " 20 60 15 \
    2 "ext2" \
    3 "ext3" \
    4 "ext4"  2>"${INPUT}"
  menuitem=$(<"${INPUT}")
  case $menuitem in
          2) fs_type_home="ext2" ;;
          3) fs_type_home="ext3" ;;
          4) fs_type_home="ext4" ;;
  esac
fi


# Decide if /home should be encrypted
if [[ -n $home_dev ]] ; then
    dialog --backtitle "LinuxBBQ Installer" --defaultno --yesno "Do you want the home partition on an encrypted partition?" 7 55
		if [ "$?" != "0" ]; then
			encrypt_home="no"
			dialog --clear
		else 
			encrypt_home="yes"
             # test for cryptsetup
             if ! [[ -f /sbin/cryptsetup ]]; then
                 dialog --backtitle "LinuxBBQ Installer" --yesno "Cryptsetup is not installed. You need to  install it and run the command, 'sudo modprobe dm-mod' before you can use encryption.Do you want to proceed without encrypting the partition?" 0 0
                    if [ "$?" != "0" ]; then
						exit 1 
					else
                        encrypt_home="no" 
                    fi
             fi
		fi
fi

# Use UUID in fstab? (and test for encrypted OS or home)
dialog --backtitle "LinuxBBQ Installer" --yesno "Would you like fstab to use the UUID to identify filesystems? This is useful if your drive order changes between reboots." 0 0
if [ "$?" != "0" ]; then
					use_uuid="no"
				else 
					if [[ $encrypt_os = "yes" ]] || [[ $encrypt_home = "yes" ]]; then
					uuid_message="--> UUIDs in fstab won't work with encrypted filesystems and\n    will not be used. Edit fstab manually after the installation."
					else
						use_uuid="yes"
					fi
fi

# Ask for swapfile and size
dialog --backtitle "LinuxBBQ Installer" --defaultno --yesno "Would you like to create a swapfile? If you already have a swap partition on your hard drive, you can skip this step." 0 0
if [ "$?" != "0" ]; then
					swapfile_on="no"
				else
					dialog --backtitle "LinuxBBQ Installer" --inputbox "Enter the size in MB \n(256, 512, 1024, ...)\n" 0 0 2>"${INPUT}"
					swapfile_count=$(<"${INPUT}")
					swapfile_on="yes"
fi


# Enter new hostname (or use the old hostname as the new one)
dialog --backtitle "LinuxBBQ Installer" --inputbox "The current hostname is ${HOSTNAME}. To change that, enter the new hostname here. To leave it unchanged, just press ENTER." 0 0 2>"${INPUT}"
 
new_hostname=$(<"${INPUT}")

# In case null was entered above as hostname, then set it to $HOSTNAME
new_hostname=${new_hostname:="$HOSTNAME"}


# Show a summary of what will be done
if [[ -z $grub_dev ]] ; then
    grub_dev_message="--> Bootloader will not be installed."
else
    grub_dev_message="--> Bootloader will be installed in $grub_dev"
fi

if [[ $encrypt_os = yes ]] ; then
    os_enc_message=", and will be encrypted."
fi

if [[ -z $home_dev ]] ; then
    home_dev_message="--> /home will not be on a separate partition."
else
    home_dev_message="--> /home will be installed on $home_dev and formatted as $fs_type_home"
fi

if [[ $swapfile_on = "yes" ]] ; then
	swapfile_on_message="--> a swap with $swapfile_count MB will be created."
else
	swapfile_on_message="--> user will manually mount an existing swap partition."
fi 

if [[ -n $home_dev ]] && [[ $encrypt_home = yes ]] ; then
    home_enc_message=", and will be encrypted."
fi

if [[ -n $boot_dev ]] ; then
    boot_dev_message="--> /boot will be installed on $boot_dev and formatted as $fs_type_boot."
fi

#if [[ $encrypt_os = yes ]] || [[ $encrypt_home = yes ]] ; then
#    proceed_message="***  IF YOU PROCEED, YOU WILL NEED TO RESPOND TO SOME QUESTIONS IN THE TERMINAL.   Be prepared to create passphrases for any encrypted partitions (several times each.) When you see the progress bar come up, you can take a break."
#fi

dialog --backtitle "LinuxBBQ Installer" --title "Summary" --yesno "  
    
$grub_dev_message
--> Operating system will be installed on $install_dev
     and formatted as $fs_type_os$os_enc_message
$home_dev_message$home_enc_message
$boot_dev_message
$uuid_message
$swapfile_on_message

Hostname: $new_hostname
   
WARNING: This is your last chance to exit before any changes are made.

Do you want to continue?\n " 0 0
if [ "$?" != "0" ]; then
	exit 0 
else
	dialog --clear
fi
# Actual installation begins here

# Unmount or close anything that might need unmounting or closing
cleanup () {
echo -e "\n Cleaning up...\n"
if $(df | grep -q /target/proc/) ; then
    umount /target/proc/
fi

if $(df | grep -q /target/dev/) ; then
    umount /target/dev/
fi

if $(df | grep -q /target/sys/) ; then
    umount /target/sys/
fi

if $(df | grep -q /target_boot) ; then
    umount -l /target_boot/
fi

if $(df | grep -q /target_home) ; then
    umount -l /target_home/
fi

if $(df | grep -q /target) ; then
    umount -l /target/
fi

if $(df | grep -q $install_dev) ; then
    umount $install_dev
fi    

if $(df | grep "\/dev\/mapper\/root-fs") ; then
    umount /dev/mapper/root-fs
fi

if [[ -h /dev/mapper/root-fs ]] ; then
    cryptsetup luksClose /dev/mapper/root-fs
fi

if $(df | grep -q $home_dev) ; then
    umount $home_dev
fi

if $(df | grep -q "\/dev\/mapper\/home-fs") ; then
    umount /dev/mapper/home-fs
fi

if [[ -h /dev/mapper/home-fs ]] ; then
    cryptsetup luksClose home-fs
fi

if $(df | grep -q $boot_dev) ; then
    umount -l $boot_dev
fi
# These next ones might be unnecessary
if [[ -d /target ]] ; then
    rm -rf /target
fi

if [[ -d /target_home ]] ; then
    rm -rf /target_home
fi

if [[ -d /target_boot ]] ; then
    rm -rf /target_boot
fi
}

cleanup

# make mount point, format, adjust reserve and mount
# install_dev must maintain the device name for cryptsetup
# install_part will be either device name or /dev/mapper name as needed.
dialog --sleep 3 --backtitle "LinuxBBQ Installer" --infobox "\nCreating filesystem on $install_dev...\n" 5 40
mkdir /target ;  check_exit
if [[ $encrypt_os = yes ]] ; then
    dialog --backtitle "LinuxBBQ Installer" --msgbox "\nYou will need to create a passphrase." 5 50
    cryptsetup luksFormat "$install_dev" ; check_exit
    dialog --sleep 3 --backtitle "LinuxBBQ Installer" --infobox "\nEncrypted partition for $install_dev created. Opening it...\n" 7 28
    cryptsetup luksOpen "$install_dev" root-fs ; check_exit
    install_part="/dev/mapper/root-fs"
else
    install_part="$install_dev"
fi 
mke2fs -t $fs_type_os "$install_part" ; check_exit 
tune2fs -r 10000 "$install_part" ; check_exit 
mount "$install_part" /target ; check_exit 

# make mount point for separate home if needed
# and add /home/* to the excludes list if it's not already there
if [[ -n $home_dev ]] ; then
    dialog --sleep 3 --backtitle "LinuxBBQ Installer" --infobox "\nCreating filesystem on $home_dev...\n" 5 40
    mkdir /target_home ; check_exit
    if [[ $encrypt_home = yes ]]; then
        dialog --backtitle "LinuxBBQ Installer" --msgbox "\nYou will need to create a passphrase.\n" 5 50
        cryptsetup luksFormat "$home_dev"
        check_exit
    dialog --sleep 3 --backtitle "LinuxBBQ Installer" --infobox "\nEncrypted partition for $home_dev created. Opening it...\n" 6 28
        cryptsetup luksOpen "$home_dev" home-fs
        check_exit
        home_part="/dev/mapper/home-fs"
    else
        home_part=$home_dev
fi
    mke2fs -t $fs_type_home "$home_part" ; check_exit
    tune2fs -r 10000 "$home_part" ; check_exit
    mount "$home_part" /target_home ; check_exit
    if ! $(grep -q "\/home\/\*" "$rsync_excludes"); then
        echo "- /home/*" >> "$rsync_excludes"
    fi
fi

# make mount point for separate /boot if needed
# and add /boot/* to the excludes list if it's not already there
# allow default for reserved blocks (don't need tune2fs here)
if [[ -n $boot_dev ]] ; then
    mkdir /target_boot ; check_exit
    mke2fs -t $fs_type_boot $boot_dev ; check_exit
    mount $boot_dev /target_boot
    if ! $(grep -q "\/boot\/\*" "$rsync_excludes"); then
        echo "- /boot/*" >> "$rsync_excludes"
    fi
fi


# make sure there's not a leftover entry in excludes list for /home/*
# or /boot/* from a previous run if not needed this time.
if [[ -z $boot_dev ]] ; then
    sed -i 's:- /boot/\*::' "$rsync_excludes"
fi

if [[ -z $home_dev ]] ; then
    sed -i 's:- /home/\*::' "$rsync_excludes"
fi


# copy everything over except the things listed in the exclude list
dialog --sleep 1 --backtitle "LinuxBBQ Installer" --infobox "\n Copying system to new partition...\n" 5 45
rsync -av / /target/ --exclude-from="$rsync_excludes" --exclude=/home/*/.gvfs|dialog --backtitle "LinuxBBQ Installer" --title "Copying..." --progressbox 0 0 

# copy separate /home if needed
if [[ -n $home_part ]] ; then
    dialog --sleep 1 --backtitle "LinuxBBQ Installer" --infobox "\n Copying home folders to new partition...\n" 5 45
    rsync -aq /home/ /target_home/  --exclude-from="$home_boot_excludes"
fi

# copy separate /boot if needed
if [[ -n $boot_dev ]] ; then
    dialog --sleep 1 --backtitle "LinuxBBQ Installer" --infobox"\n Copying files to boot partitions...\n" 5 45
    rsync -aq /boot/ /target_boot/  --exclude-from="$home_boot_excludes"
fi

# create swap
if [[ $swapfile_on = "yes" ]] ; then
	dialog --sleep 1 --backtitle "LinuxBBQ Installer" --infobox "\n Making a swap file...\n" 5 45
	dd if=/dev/zero of=/target/swapfile bs=1MB count="$swapfile_count" ; check_exit 
	mkswap /target/swapfile ; check_exit 
fi


# Disallow mounting of all fixed drives with pmount
if [[ -f /target/etc/pmount.allow ]] ; then
	if [[ $pmount_fixed = "no" ]] ; then
		sed -i 's:/dev/sd\[a-z\]:#/dev/sd\[a-z\]:' /target/etc/pmount.allow
	fi
fi

# Re-enable updatedb if it was disabled by snapshot
if [[ -e /target/usr/bin/updatedb.mlocate ]] ; then
	if [[  $enable_updatedb = "yes" ]] ; then
		chmod +x /target/usr/bin/updatedb.mlocate
	fi
fi

# Disable auto-login

#while true; do
#	echo -n " Disable auto-login?
#	(Y/n)
#	"
#	read ans
#	case $ans in
disable_auto_desktop="yes"
#			break ;;
#	esac
#done


if [[ $disable_auto_desktop = "yes" ]]; then

	#gdm
    if [[ -f /target/etc/gdm/gdm.conf ]]; then
        sed -i 's/^AutomaticLogin/#AutomaticLogin/' /target/etc/gdm/gdm.conf
    fi

	#gdm3
    if [[ -f /target/etc/gdm3/daemon.conf ]]; then
        sed -i 's/^AutomaticLogin/#AutomaticLogin/' /target/etc/gdm3/daemon.conf
    fi

	#lightdm
	if [[ -f /target/etc/lightdm/lightdm.conf ]]; then
		sed -i 's/^autologin/#autologin/g' /target/etc/lightdm/lightdm.conf
	fi

	#kdm
	if [ -f /target/etc/default/kdm.d/live-autologin ]; then
		rm -f /target/etc/default/kdm.d/live-autologin
	fi

	if [ -f /target/etc/kde3/kdm/kdmrc ]; then
		sed -i -e 's/^AutoLogin/#AutoLogin/g' /target/etc/kde3/kdm/kdmrc
		sed -i -e 's/^AutoReLogin/#AutoReLogin/g' /target/etc/kde3/kdm/kdmrc
	fi

	if [ -f /target/etc/kde4/kdm/kdmrc ]; then
		sed -i -e 's/^AutoLogin/#AutoLogin/g' /target/etc/kde4/kdm/kdmrc
		sed -i -e 's/^AutoReLogin/#AutoReLogin/g' /target/etc/kde4/kdm/kdmrc
	fi

	#trinity
	if [[ -f /target/etc/default/kdm-trinity.d/live-autologin ]]; then
		sed -i 's/^AUTOLOGIN/#AUTOLOGIN/g' /target/etc/default/kdm-trinity.d/live-autologin
	fi
	
	if [ -f /target/etc/trinity/kdm/kdmrc ]; then
		sed -i -e 's/^AutoLogin/#AutoLogin/g' /target/etc/trinity/kdm/kdmrc
		sed -i -e 's/^AutoReLogin/#AutoReLogin/g' /target/etc/trinity/kdm/kdmrc
	fi

#	# console autologin - only works for inittab/sysvinit
#	if grep -q "respawn:/bin/login -f" /target/etc/inittab ; then
#		mv /target/etc/inittab /target/etc/inittab.console_autologin
#		cp /usr/lib/bbqinstaller/inittab.debian /target/etc/inittab
#	fi
fi


# copy the real update-initramfs back in place
dialog --sleep 1 --backtitle "LinuxBBQ Installer" --infobox "\n Copying update-initramfs...\n" 5 45
if [[ -f /target/usr/sbin/update-initramfs.distrib ]] ; then
    cp /target/usr/sbin/update-initramfs.distrib /target/usr/sbin/update-initramfs
fi
if [[ -f /target/usr/sbin/update-initramfs.debian ]] ; then
    cp /target/usr/sbin/update-initramfs.debian /target/usr/sbin/update-initramfs
fi

# Change hostname
if ! [[ $new_hostname = $HOSTNAME ]]; then
	sed -i "s/$HOSTNAME/$new_hostname/" /target/etc/hostname
	sed -i "s/$HOSTNAME/$new_hostname/g" /target/etc/hosts
fi

# setup fstab    ### TEST FOR UUID AND ENCRYPTION HAPPENS ABOVE THIS!!!

# add entry for root filesystem
if [[ $use_uuid = yes ]]; then
	install_part="$(blkid -s UUID $install_dev | awk '{ print $2 }')"
fi
dialog --sleep 1 --backtitle "LinuxBBQ Installer" --infobox "\n Creating /etc/fstab...\n " 5 45
echo -e "proc\t\t/proc\tproc\tdefaults\t0\t0
/swapfile\tswap\tswap\tdefaults\t0\t0
$install_part\t/\t$fs_type_os\tdefaults,noatime\t0\t1" >> /target/etc/fstab

if [[ $swapfile_on = yes ]] ; then
echo -e "/swapfile\tswap\tswap\tdefaults\t0\t0" >> /target/etc/fstab
check_exit
fi

# add entry for /home to fstab if needed
if [[ -n $home_part ]] ; then
	if [[ $use_uuid = yes ]]; then
		home_part="$(blkid -s UUID $home_dev | awk '{ print $2 }')"
	fi
	dialog --sleep 1 --backtitle "LinuxBBQ Installer" --infobox "\n Adding /home entry to fstab...\n " 5 45
    echo -e "$home_part\t/home\t$fs_type_home\tdefaults,noatime\t0\t2" >> /target/etc/fstab
    check_exit
fi

# add entry for /boot to fstab if needed
if [[ -n $boot_dev ]] ; then
	if [[ $use_uuid = yes ]]; then
		boot_part="$(blkid -s UUID $boot_dev | awk '{ print $2 }')"
	else
		boot_part="$boot_dev"
	fi
	dialog --sleep 1 --backtitle "LinuxBBQ Installer" --infobox "\n Adding /boot entry to fstab...\n " 5 45
    echo -e "$boot_part\t/boot\t$fs_type_boot\tdefaults,noatime,\t0\t1" >> /target/etc/fstab
    check_exit
fi


# Add entry for root filesystem to crypttab if needed
if [[ $encrypt_os = yes ]] ; then
	dialog --sleep 1 --backtitle "LinuxBBQ Installer" --infobox  "\n Adding $install_part entry to crypttab...\n " 5 45
    echo -e "root-fs\t\t$install_dev\t\tnone\t\tluks" >> /target/etc/crypttab
fi

# Add entry for /home to crypttab if needed
if [[ $encrypt_home = yes ]] ; then
	dialog --sleep 1 --backtitle "LinuxBBQ Installer" --infobox "\n Adding $home_part entry to crypttab...\n " 5 45
    echo -e "home-fs\t\t$home_dev\t\tnone\t\tluks" >> /target/etc/crypttab
fi


# mount stuff so grub will behave (so chroot will work)
#echo -e "\n Mounting tmpfs and proc...\n"
mount -t tmpfs --bind /dev/ /target/dev/ ; check_exit 
mount -t proc --bind /proc/ /target/proc/ ; check_exit 
mount -t sysfs --bind /sys/ /target/sys/ ; check_exit 


# Re-enable freshclam if it was disabled by snapshot 		##### This ain't perfect, but it works!
if type -p freshclam ; then
	if [[ $enable_freshclam = "yes" ]] ; then
		if ! [[ -h /target/etc/rc2.d/S02clamav-freshclam ]] ; then
			chroot /target update-rc.d clamav-freshclam defaults
		fi
	fi
fi


# Disable root login through ssh for the installed system
if [[ -f /etc/ssh/sshd_config ]] ; then
	if [[ $root_ssh = "no" ]] ; then
		sed -i~ 's/PermitRootLogin yes/PermitRootLogin no/' /target/etc/ssh/sshd_config
	fi
fi


# Setup GRUB 
dialog --sleep 1 --backtitle "LinuxBBQ Installer" --infobox "\n Installing the boot loader...\n " 5 45

# If /boot is separate partition, need to mount it in chroot for grub
if [[ -n $boot_dev ]] ; then
    chroot /target mount $boot_dev /boot
fi

if [[ -n $grub_dev ]]; then
    dialog --sleep 1 --backtitle "LinuxBBQ Installer" --infobox  "\n Installing the boot loader...\n " 5 45
    chroot /target grub-install $grub_dev >> "$error_log"; check_exit
fi

# Run update-initramfs to include dm-mod if using encryption
if [[ $encrypt_os = yes ]] || [[ $encrypt_home = yes ]] ; then
    chroot /target update-initramfs -u
fi

if [[ -n $grub_dev ]]; then
    chroot /target update-grub ; check_exit 
fi

## we'd get a username here. For now, the username is bbq or root

#dialog --backtitle "LinuxBBQ Installer" --title "Username" --inputbox "Enter your login name." 8 50 2>"${INPUT}"
#username=$(<"${INPUT}")

## prompt for a password. breakage starts here :(

dialog --backtitle "LinuxBBQ Installer" --title "User Password" --infobox "Enter your user password now, press [Enter], then enter your password again. This will not be echoed, so be careful." 0 0

## this part doesn't do as we like. Ideas?

#password=$(<"${INPUT}")
#
#echo "$username:$password" > /tmp/newusers.conf
#echo "root:$password" >> /tmp/newusers.conf
#cp /tmp/newusers.conf /target/tmp/newusers.conf
#chroot /target deluser bbq
#chroot /target rm -rf home/bbq
#chroot /target useradd -s /bin/bash -G sudo,audio,netdev -m $username
#chroot /target cat tmp/newusers.conf | chpasswd
#chroot /target rm tmp/newusers.conf
#rm /tmp/newusers.conf

## so for now, use the cheap method
chroot /target passwd

# call cleanup function
cleanup

dialog --sleep 1 --backtitle "LinuxBBQ Installer" --msgbox "Done! You may now reboot into the new system. Type  reboot  or  poweroff. Remember to remove the media before restarting the computer. You can login as  root  with the password you provided and create normal users with  adduser username  anytime.\n" 0 0
exit 0
