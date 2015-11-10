#!/bin/bash
#
# check_kernel.sh - Check whether a kernel update has been done since the last
#                   reboot if so, exit with a message and exit status of 1 else
#                   exit with exit status 0
#
# CREATED:  A long time ago 
# MODIFIED: 2010-11-10 12:44

KERNELPKG="kernel26"

last_reboot=$(date -d "$(cat /proc/uptime | cut -d' ' -f1) seconds ago" +"%s")
dates_inst=$(sed -r "s/\[(.*)\].*upgraded $KERNELPKG.*/\1,/;tx;d;:x" /var/log/pacman.log | uniq)
dates_inst=$(echo $dates_inst | sed -r "s/, /,/g")

IFS=","
dates=( $dates_inst )
unset IFS

count=${#dates[*]}
date_diff=1
while [[ $count -gt 0 ]] && [[ $date_diff -gt 0 ]]
do
    count=$(( $count - 1 ))
    last_inst=$(date +"%s" -d "${dates[$count]}")
    date_diff=$(( $last_inst - $last_reboot ))
done

run_kernel=$(sed -r "s/^\[${dates[$count]}\] upgraded $KERNELPKG \(.* -> (.*)\)$/\1/;tx;d;:x" /var/log/pacman.log) 
kernel_inst=$(date +"%s" --date "$(tac /var/log/pacman.log | sed -r "s/\[(.*)\].*$KERNELPKG.*/\1/;tx;d;:x;q")")
reboot=$(( $kernel_inst - $last_reboot ))

echo "Running:   " $run_kernel
echo "Installed: " $(pacman -Q kernel26 | cut -d" " -f2)

if [[ $reboot > 0 ]]
then
    echo -n "A new kernel has been installed since the last reboot.  "
    echo "Please schedule a reboot."
    exit 1
else
    exit 0
fi

