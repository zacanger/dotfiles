#!/usr/bin/env bash
[ "root" != "$USER" ] && exec sudo $0 "$@"
version="bbqsnapshot-9.0.5-4 (20120805)"
# based primarily on bbqsnapshot-8.0.4 by Dean Linkous with ideas
# borrowed from dzsnapshot-gui.sh by David Hare, which was based on an
# earlier version of this script.
# Copyright: fsmithred@gmail.com 2011, 2012
# License: GPL-3
# This is free software with NO WARRANTY. Use at your own risk!

# DESCRIPTION
# This script makes a copy of your system with rsync and then creates
# an iso file to be used as a live-cd. There are options in the config
# file to change the location of the copy and the location of the final
# iso file, in case there's not enough room on the system drive. Read
# the config file for more options. (bbqsnapshot.conf)

# If you want to change any defaults, change them in the configfile.
# Default is /etc/bbqsnapshot.conf
# If you want to use a different config file for testing,
# either change this variable here or use the -c, --config option on
# the command-line. (Command-line option will supercede this setting.) 
# Normally, users should not edit anything in this script.
configfile="/etc/bbqsnapshot.conf"

show_help () {
	printf "$help_text"
	exit 0
}

help_text="
	Usage:  $0  [option]
	
	Run with no options to create .iso file for a live, bootable CD
	copy of the running system.
	
	valid options:
		-h, --help		show this help text
		-v, --version	display the version information
		-c, --config	specify a different config file

	*** See $configfile for information about settings.

"

while [[ $1 == -* ]]; do
	case "$1" in
	
		-h|--help)
			show_help ;;
		
		-v|--version)
			printf "\n$version\n\n"
			exit 0 ;;
		
		-c|--config)
			configfile="$2"
			break ;;
		
		*) 
			printf "\t invalid option: $1 \n\n"
			printf "\t Try:  $0 -h for full help. \n\n"
			exit 1 ;;
    esac
done		


##### This can be removed from the final version
#if ! [[ -d /usr/lib/bbqsnapshot/iso/live ]]; then
#	mkdir -p /usr/lib/bbqsnapshot/iso/live
#fi


bbqsnapshot_configuration () {
if [[ -f $configfile ]]; then
    source $configfile
fi
# Check for values in $configfile and use them.
# If any are unset, these defaults will be used.
error_log=${error_log:="/var/log/bbqsnapshot_errors.log"}
work_dir=${work_dir:="/home/work"}
snapshot_dir=${snapshot_dir:="/home/snapshot"}
save_work=${save_work:="no"}
snapshot_excludes=${snapshot_excludes:="/usr/lib/bbqsnapshot/snapshot_exclude.list"}
kernel_image=${kernel_image:="/vmlinuz"}
initrd_image=${initrd_image:="/initrd.img"}
stamp=${stamp:=""}
snapshot_basename=${snapshot_basename:="snapshot"}
make_md5sum=${make_md5sum:="no"}
make_isohybrid=${make_isohybrid:="yes"}
edit_boot_menu=${edit_boot_menu:="no"}
iso_dir=${iso_dir:="/usr/lib/bbqsnapshot/iso"}
boot_menu=${boot_menu:="isolinux.cfg"}
text_editor=${text_editor:="$(type -p nano)"}
}

bbqsnapshot_configuration

# Record errors in a logfile.
exec 2>"$error_log"


# Check that user is root.
#[[ $(id -u) -eq 0 ]] || { echo -e "\t Y U NO ROOT? \n" ; exit 1 ; }


# Function to check for old snapshots and filesystem copy
check_copies () {
# Check how many snapshots already exist and their total size
if [[ -d $snapshot_dir ]]; then
	snapshot_count=$(ls "$snapshot_dir"/*.iso | wc -l)
	snapshot_size=$(du -sh "$snapshot_dir" | awk '{print $1}')
	if [[ -z $snapshot_size ]]; then
		snapshot_size="0 bytes"
	fi
else
	snapshot_count="0"
	snapshot_size="0 bytes"
fi

# Check for saved copy of the system
if [[ -d "$work_dir"/myfs ]]; then
    saved_size=$(du -sh "$work_dir"/myfs | awk '{ print $1 }')
    saved_copy=$(echo "* You have a saved copy of the system using $saved_size of space
   located at $work_dir/myfs." 7 65)
fi


 Create a message to say whether the filesystem copy will be saved or not.
if [[ $save_work = "yes" ]]; then
	save_message=$(echo "* The temporary copy of the filesystem will be saved 
   at $work_dir/myfs." 7 55)
else
	save_message=$(echo "* The temporary copy of the filesystem will be created 
   at $work_dir/myfs and removed when this program finishes." 7 65)
fi
}


# Create snapshot_dir and work_dir if necessary.
check_directories () {

# Check that snapshot_dir exists
if ! [[ -d $snapshot_dir ]]; then
	mkdir -p "$snapshot_dir"
	chmod 777 "$snapshot_dir"
fi


# Check that work directories exist or create them.
if [[ $save_work = "no" ]]; then
    if [[ -d $work_dir ]]; then
        rm -rf "$work_dir"
    fi
    mkdir -p "$work_dir"/iso
    mkdir -p "$work_dir"/myfs
elif [[ $save_work = "yes" ]]; then
	if ! [[ -d $work_dir ]]; then
	    mkdir -p "$work_dir"/iso
        mkdir -p "$work_dir"/myfs
    fi
fi
}


# Check disk space on mounted /, /home, /media, /mnt, /tmp
check_space () {
disk_space=$(df -h | awk '/Filesystem/ { print $1 "\t " $2 "\t" $3 "\t" $4 "\t" $5 "  " $6 }' ;
df -h | awk '$6=="/" { print $1 "\t " $2 "\t" $3 "\t" $4 "\t" $5 "  " $6 }' ;
df -h | awk '$6=="/home" { print $1 "\t " $2 "\t" $3 "\t" $4 "\t" $5 "  " $6 }' ;
df -h | awk '$6~"/mnt" { print $1 "\t " $2 "\t" $3 "\t" $4 "\t" $5 "  " $6 }' ;
df -h | awk '$6~"/media" { print $1 "\t " $2 "\t" $3 "\t" $4 "\t" $5 "  " $6 }' ;
# Next line is useful only if you have an encrypted volume mounted at location not already listed.
df -h | awk '$1~"/dev/mapper" { print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "  " $6 }' ;
df -h | awk '$6=="/tmp" { print $1 "\t " $2 "\t" $3 "\t" $4 "\t" $5 "  " $6 }' ;)


# Create a warning message if /tmp is on a separate partition (REMOVED for tmpfs in wheezy)
#tmp_warning=$(df -h | awk '$6=="/tmp" { printf "\nWarning: /tmp is on a separate partition. Make sure it has enough free space or use a different location to copy the filesystem." }')
}


# Show current settings and disk space 
report_space () {
dialog --clear --title "Snapshot Tool" --backtitle "BBQSnapshot" --msgbox " 

 * You have $snapshot_count snapshots taking up $snapshot_size of disk space.
 
 * The snapshot directory is currently set to $snapshot_dir
 $tmp_warning

 You can change these and other settings by editing 
 $configfile.


 Current disk usage:
 (For complete listing, exit and run 'df -h')

 $disk_space
 
 Press ENTER to proceed or hit ctrl-c to exit." 32 85
}

dialog --clear --backtitle "BBQSnapshot" --msgbox "Welcome to the Snapshot Tool   Hit Enter to start..." 8 32;
check_copies
check_directories
check_space
#report_space


# The real work starts here
cd "$work_dir"

# @@@@  Warning: This will replace these files in custom iso_dir  @@@@@
#copy some isolinux stuff from the system to the snapshot
rsync -aq /usr/lib/syslinux/isolinux.bin "$iso_dir"/isolinux/ 
rsync -aq /usr/lib/syslinux/vesamenu.c32 "$iso_dir"/isolinux/  
# Let iso/, vmlinuz and initrd.img get copied, even if work_dir was 
# saved, in case they have changed.
rsync -aq "$iso_dir"/ "$work_dir"/iso/  
cp "$kernel_image" "$work_dir"/iso/live/ 
cp "$initrd_image" "$work_dir"/iso/live/ 


# Copy the filesystem
rsync -av --progress / myfs/ --delete --exclude="$work_dir" --exclude="$snapshot_dir" --exclude-from="$snapshot_excludes"|dialog --backtitle "LinuxBBQ Snapshot" --programbox "Copying files... Please be patient" 6 0


# Allow all fixed drives to be mounted with pmount
if [[ $pmount_fixed = "yes" ]] ; then
	if [[ -f /etc/pmount.allow ]]; then
		sed -i 's:#/dev/sd\[a-z\]:/dev/sd\[a-z\]:' "$work_dir"/myfs/etc/pmount.allow
	fi
fi

# Disable updatedb for the live-CD
if [[ $disable_updatedb = "yes" ]] ; then
	if [[ -x "$work_dir"/myfs/usr/bin/updatedb.mlocate ]]; then
		chmod -x "$work_dir"/myfs/usr/bin/updatedb.mlocate
	fi
fi

# Disable freshclam for the live-CD
if [[ $disable_freshclam = "yes" ]] ; then
	for link in "$work_dir"/myfs/etc/rc*.d/*clamav-freshclam ; do
		rm $link
	done
fi

# Enable root login through ssh for live-CD
if [[ $root_ssh = "yes" ]] ; then
	sed -i 's/PermitRootLogin no/PermitRootLogin yes/' "$work_dir"/myfs/etc/ssh/sshd_config
fi

# Need to define $filename here (moved up from genisoimage)
# and use it as directory name to identify the build on the cdrom.
# and put package list inside that directory
if [[ $stamp = "datetime" ]]; then
    # use this variable so iso and md5 have same time stamp
	filename="$snapshot_basename"-$(date +%Y%m%d_%H%M).iso
else
    n=1
    while [[ -f "$snapshot_dir"/snapshot$n.iso ]]; do
        ((n++))
    done
    filename="$snapshot_basename"$n.iso
fi

# Remove any old package-list directories (only works for same basename)
for dir in "$work_dir"/iso/"${snapshot_basename}"* ; do
	rm -r "$dir" 
done

mkdir -p "$work_dir"/iso/"${filename%.iso}"
dpkg -l | grep "ii" | awk '{ print $2 }' > "$work_dir"/iso/"${filename%.iso}"/package_list


# Pause to edit the boot menu or anything else in $work_dir
bbq-distro-defaults-snap
"$text_editor" "$work_dir"/iso/isolinux/"$boot_menu"


# Squash the filesystem copy
mksquashfs myfs/ iso/live/filesystem.squashfs -comp xz | dialog --backtitle "LinuxBBQ Snapshot" --title "Squashing the ISO... This might take a while" --progressbox 6 0

# This code is redundant, because $work_dir gets removed later, but
# it might help by making more space on the hard drive for the iso.
if [[ $save_work = "no" ]]; then
    rm -rf myfs
fi


# create the iso file, make it isohybrid
# create md5sum file for the iso

genisoimage -v -v -r -J -l -D -o "$snapshot_dir"/"$filename" -cache-inodes -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table iso/ 


if [[ $make_isohybrid = "yes" ]]; then
	isohybrid "$snapshot_dir"/"$filename" 
fi

if [[ $make_md5sum = "yes" ]]; then
	md5sum "$snapshot_dir"/"$filename" > "$snapshot_dir"/"$filename".md5
	cat "$snapshot_dir"/"$filename".md5
fi


# Cleanup
if [[ $save_work = "no" ]]; then
    cd /
    rm -rf "$work_dir" 
else
    rm "$work_dir"/iso/live/filesystem.squashfs
fi

dialog --backtitle "BBQSnapshot" --infobox "All finished. Bye..." 6 20;

exit 0
