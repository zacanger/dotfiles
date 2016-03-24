#!/usr/bin/env bash

#   Prints out a disk usage report.
#
#   This script was created to monitor a server that had a habit of filling
#   all it's free space with log and cache files and fail to clear them.
#
#   The report gives you an overview of disk usage, and then spot-checks
#   common log and cache file locations printing out their total size in MB.
#
#   The list is sorted according to folder size, letting you identify folders
#   that fill up to quickly or too often.

# use colors if available
[ -f "$HOME/scripts/colors" ] && source $HOME/scripts/colors

command -v awk >/dev/null 2>&1 || { echo -e "$Color_Red ERROR:$Color_Off $Color_White awk$Color_Off not found. Please install it and try again"; exit 1; }
command -v du >/dev/null 2>&1 || { echo -e "$Color_Red ERROR:$Color_Off $Color_White du$Color_Off not found. Please install it and try again"; exit 1; }
command -v df >/dev/null 2>&1 || { echo -e "$Color_Red ERROR:$Color_Off $Color_White df$Color_Off not found. Please install it and try again"; exit 1; }

# grab the % usage of the primary partition (typically line 2, col 5 on df)
read USAGE <<< $( df -h | awk 'FNR == 2 { print $5 }' )

# Make red if usage is above 60
if [ ${USAGE%?} -lt 60 ]; then
    Color_On=$Color_Green
else
    Color_On=$Color_Red
fi

echo -e "\nDisk Usage Report"
echo -e "-----------------\n"

echo -e "Disk usage: \t $Color_On$USAGE$Color_Off\n"

df -h

echo -e "\nLog file spot check:\n"

# Adding output to temp file so we can sort it later
# -sh provides human readable summary
# -BM sets the block size to Megabytes
du -shBM /tmp 2>/dev/null >> /tmp/du$$
du -shBM /var/log 2>/dev/null >> /tmp/du$$
du -shBM /srv/www/*/logs 2>/dev/null >> /tmp/du$$
du -shBM /srv/www/*/*/*/wp-content/cache 2>/dev/null >> /tmp/du$$
du -shBM /srv/www/*/*/*/wp-content/uploads 2>/dev/null >> /tmp/du$$

sort -nr /tmp/du$$

rm /tmp/du$$

