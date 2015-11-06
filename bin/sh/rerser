#! /bin/sh

# Search for files in nested directories.
# place in "$XDG_CONFIG_HOME/dmenfm/plugins/browser"
# requires dmenfm "no_scan" patch
# does not respect show_hidden, show_backup, always_open

length=${#PWD}

if [ "$PWD" != "/" ]; then
    let length=$length+2
fi

file=`find $PWD \( ! -regex '.*/\..*' \) 2>/dev/null | cut -n -b "$length-" | $menu -p "Searching $PWD: "`

if [ -n "$file" ]; then
    #if [ "$PWD" != "/" ]; then
    #    file="$PWD/$file"
    #fi
    no_scan="1"
else
    unset file
fi

unset length

