#!/usr/bin/env bash

# siv2 reincarnated with unicode block elements (256 color mode only)
#
# Using Unicode block elements we get square pixels, which doubles the
# resolution in y direction compared to siv2.
#
# Credits for that idea go to ponysay.

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
function rgbtoescapecolor(r_in, g_in, b_in)
{
    r = int(r_in / 51)
    g = int(g_in / 51)
    b = int(b_in / 51)

    if (r == g && g == b)
    {
        # Try to use the full grayscale ramp. Full white and
        # full black are not part of the ramp. Note that we have to use
        # the original *_in to avoid using the value divided by 51.
        if (r_in == 255)
            return 231
        else if (r_in == 0)
            return 16
        else
            return int((r_in / 255) * 24) + 232
    }
    else
    {
        # Find the nearest neighbor in XTerms 6x6x6 color
        # cube.
        return 16 + r * 36 + g * 6 + b
    }
}

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

            ansi_last = rgbtoescapecolor(r_fg, g_fg, b_fg)
            ansi_now = rgbtoescapecolor(r_bg, g_bg, b_bg)

            printf "\033[38;5;%dm\033[48;5;%dm%s\033[0m",
                ansi_last, ansi_now, "▀"
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
