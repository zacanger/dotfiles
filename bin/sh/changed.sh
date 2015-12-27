#!/bin/sh
echo Search whole filesystem for changed files in the last $1 minutes
find /bin /dev /etc /home /lib /media /mnt /opt /root /sbin /srv /tmp /usr /var -cmin -$1
