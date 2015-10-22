#!/bin/bash

clear 
 
GRUB_TARGET="/mnt/repairs"
  
setup () {
if [[ ! -d "$GRUB_TARGET" ]]; then
mkdir -p "$GRUB_TARGET"
fi
}
   
bind_it () {
mount --bind $1 $2
}
    
sudo blkid -o list

read -p "Please enter the device you wish to install grub to (MBR): "
DEVICE_INST="$REPLY"
read -p "Please enter the partition device node on which your installation exists (Your linux install): "
PARTITION_INST="$REPLY"
setup
      
# Attempt mount
mount "$PARTITION_INST" "$GRUB_TARGET"
if [[ $? != 0 ]]; then
echo "Could not mount the device. Aborting"
exit 1
fi
       
for mountpoint in "/dev/" "/dev/pts" "/dev/shm" "/proc" "/sys"; do
bind_it "$mountpoint" "$GRUB_TARGET$mountpoint"
done
        
# run teh commands
chroot "$GRUB_TARGET" "grub-install" "$DEVICE_INST"
chroot "$GRUB_TARGET" "update-grub"
         
for mountpoint in "/dev/pts" "/dev/shm" "/dev" "/proc" "/sys"; do
umount "$GRUB_TARGET$mountpoint"
done
          
umount "$GRUB_TARGET"
