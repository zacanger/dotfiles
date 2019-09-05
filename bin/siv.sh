#!/usr/bin/env bash

# siv3 reincarnated with unicode block elements (true color mode only)
#
# We now use more modern escape sequences which allow the use of 24 bit
# colors.

size="$(($(tput cols) - 2))x$(($(tput lines) - 2))"

while getopts s:n name
do
    case $name in
        s)
            size="$OPTARG"
            ;;
        n)
            unscaled=1
            ;;
    esac
done
shift $((OPTIND - 1))

wid="${size%x*}"
hei="${size#*x}"
hei=$((hei * 2))
(( hei % 2 != 0 )) && (( hei++ ))
distorted_size=${wid}x${hei}

if (( unscaled ))
then
    sizeargs=()
else
    sizeargs=(-resize "$distorted_size")
fi

while (( $# > 0 ))
do
    # Convert the image into a PPM image which can easily be read by
    # awk.
    convert \
        -quiet \
        -compress none \
        -depth 8 \
        "${sizeargs[@]}" \
        "$1" "ppm:-" |
        grep -v '^$' | grep -v '^#' |
        gawk '
{
    if (NR <= 3)
    {
        if (NR == 2)
        {
            wid = $1
            hei = $2
        }
    }
    else
    {
        # Buffer the complete image to account for weird line breaks.
        # One line in the file is not neccessarily one line in the
        # image.
        for (i = 1; i <= NF; i++)
        {
            rgb_values_num++
            rgb_values[rgb_values_num] = $i
        }
    }
}

END {
    for (y = 0; y < hei; y += 2)
    {
        for (x = 0; x < 3 * wid; x += 3)
        {
            r_fg = rgb_values[y * 3 * wid + x + 1]
            g_fg = rgb_values[y * 3 * wid + x + 2]
            b_fg = rgb_values[y * 3 * wid + x + 3]

            r_bg = rgb_values[(y + 1) * 3 * wid + x + 1]
            g_bg = rgb_values[(y + 1) * 3 * wid + x + 2]
            b_bg = rgb_values[(y + 1) * 3 * wid + x + 3]

            printf "\033[38;2;%d;%d;%dm\033[48;2;%d;%d;%dm%s\033[0m",
                r_fg, g_fg, b_fg,
                r_bg, g_bg, b_bg,
                "▀"
        }
        printf "\n"
    }
}
'

    # One empty line between two images.
    shift
    if (( $# > 0 ))
    then
        echo
    fi
done
