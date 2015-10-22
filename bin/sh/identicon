#!/usr/bin/env bash

# identicon.sh
# Copyright (C) 2011-2014 by Harald Lapp <harald@octris.org>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#
# This script can be found at:
# https://github.com/aurora/identicon
#

#
# This is a re-implementation of the PHP script "PHP identicons" found at
# http://identicons.sf.net/ 
#
# The original script requires PHP and the GD library, the re-implemented
# script is intented to be called from command-line and requires a bash, 
# imagemagick (only if output is not SVG) and bc.
#

# init
# 
spriteZ=128                                         # size of each sprite
spriteZCoord=$((spriteZ - 1))                       # used for (x,y) coordinates
draw=""                                             # stores MVG commands to draw
ret=""                                              # stores return values of functions

out="-"                                             # generated identicon will be output to stdout per default
fmt="png"                                           # output file format
back="white"                                        # background color of identicon
hash=""                                             # hash to generate identicon from
size=64                                             # size of identicon to create
swirl=0                                             # swirl by degrees

# process command-line parameters
#
function showusage {
    echo "usage: $0 [arguments]

-H  hash to use for generating identicon
-s  size of generated identicon in pixels (default: 64)
-w  apply swirl effect, expects a degree value (eg.: 180, -60, etc.) (default: 0)
-o  name of file to save created image to (default: stdout)
-t  use transparent background (default: white)
-h  display this usage information
"
}

while getopts H:s:w:o:th OPTIONS; do
    case $OPTIONS in
        H)
            hash=$OPTARG;;
        s)
            size=$OPTARG;;
        w)
            swirl=$OPTARG;;
        o) 
            out=$OPTARG;;
        t)
            back="transparent";;
        h)
            showusage
            exit 1;;
        *)
            showusage
            exit 1;;
    esac
done

if [[ "$out" =~ ^([0-9a-zA-Z-]+):(.+) ]]; then
    fmt=$(echo ${BASH_REMATCH[1]} | tr "[:upper:]" "[:lower:]")
    out=${BASH_REMATCH[2]}
fi

if [ "$fmt" = "svg" ]; then
    spriteZCoord=$spriteZ
fi

if [ -z "$hash" ]; then
    hash=`cat /dev/urandom | LC_ALL=C tr -dc 'a-fA-F0-9' | fold -w 32 | head -n 1`
    
    echo $hash >/dev/stderr
fi

if ! [[ "$hash" =~ ^[0-9a-fA-F]{17,}$ ]]; then
    echo "warning: empty or wrong hash value"
    
    showusage
    exit 1
fi

if [ "$size" -le "0" ]; then
    showusage
    exit 1
fi

case ${swirl#[-+]} in
    *[!0-9]*) 
        showusage
        exit 1;;
    *)
        if [ "$fmt" = "svg" ] && [ $swirl -ne 0 ]; then
            echo "warning: swirl effect is not supported for SVG file format"
            
            showusage
            exit 1
        fi
        ;;
esac

# generate sprite for corners and sides 
# 
function getsprite {
    local shape=$1
    local RGB=$2
    local rotation=$3
    local tX=$4
    local tY=$5
    local xOffs=0
    local yOffs=0
    local points=""
    local point=""
    local polygon=""
    
    case "$shape" in
        0)  # triangle
            points="0.5,1 1,0 1,1";;
        1)  # parallelogram
            points="0.5,0 1,0 0.5,1 0,1";;
        2)  # mouse ears
            points="0.5,0 1,0 1,1 0.5,1 1,0.5";;
        3)  # ribbon
            points="0,0.5 0.5,0 1,0.5 0.5,1 0.5,0.5";;
        4)  # sails
            points="0,0.5 1,0 1,1 0,1 1,0.5";;
        5)  # fins
            points="1,0 1,1 0.5,1 1,0.5 0.5,0.5";;
        6)  # beak
            points="0,0 1,0 1,0.5 0,0 0.5,1 0,1";;
        7)  # chevron
            points="0,0 0.5,0 1,0.5 0.5,1 0,1 0.5,0.5";;
        8)  # fish
            points="0.5,0 0.5,0.5 1,0.5 1,1 0.5,1 0.5,0.5 0,0.5";;
        9)  # kite
            points="0,0 1,0 0.5,0.5 1,0.5 0.5,1 0.5,0.5 0,1";;
        10) # trough
            points="0,0.5 0.5,1 1,0.5 0.5,0 1,0 1,1 0,1";;
        11) # rays
            points="0.5,0 1,0 1,1 0.5,1 1,0.75 0.5,0.5 1,0.25";;
        12) # double rhombus
            points="0,0.5 0.5,0 0.5,0.5 1,0 1,0.5 0.5,1 0.5,0.5 0,1";;
        13) # crown
            points="0,0 1,0 1,1 0,1 1,0.5 0.5,0.25 0.5,0.75 0,0.5 0.5,0.25";;
        14) # radioactive
            points="0,0.5 0.5,0.5 0.5,0 1,0 0.5,0.5 1,0.5 0.5,1 0.5,0.5 0,1";;
        *)  # tiles
            points="0,0 1,0 0.5,0.5 0.5,0 0,0.5 1,0.5 0.5,1 0.5,0.5 0,1";;
    esac
    
    case "$rotation" in
        0)
            xOffs=0; yOffs=0;;
        90)
            xOffs=0; yOffs=-$spriteZCoord;;
        180)
            xOffs=-$spriteZCoord; yOffs=-$spriteZCoord;;
        270)
            xOffs=-$spriteZCoord; yOffs=0;;
    esac

    # create polygon with the applied ratio
    for point in $points; do
        polygon="$polygon $(echo "${point%%,*} * $spriteZCoord + $xOffs" | bc -l),$(echo "${point##*,} * $spriteZCoord + $yOffs" | bc -l)"
    done
    
    if [ "$fmt" = "svg" ]; then
        ret="<g transform=\"translate($((tX)), $((tY)))\">
                <g transform=\"rotate($rotation)\">
                    <path d=\"M $polygon Z\" style=\"fill:$RGB\" />
                </g>
             </g>"
    else
        ret="push graphic-context
                translate $((tX)),$((tY))
                rotate $rotation
                fill $RGB      path 'M $polygon Z'
             pop graphic-context"
    fi
}
 
# generate sprite for center block
#
function getcenter {
    local shape=$1
    local fRGB=$2
    local bRGB=$3
    local tX=$4
    local tY=$5
    local points=""
    local point=""
    local polygon=""
    
    case "$shape" in
        0)  # empty
            points="";;
        1)  # fill
            points="0,0 1,0 1,1 0,1";;
        2)  # diamond
            points="0.5,0 1,0.5 0.5,1 0,0.5";;
        3)  # reverse diamond
            points="0,0 1,0 1,1 0,1 0,0.5 0.5,1 1,0.5 0.5,0 0,0.5";;
        4)  # cross
            points="0.25,0 0.75,0 0.5,0.5 1,0.25 1,0.75 0.5,0.5 0.75,1 0.25,1 0.5,0.5 0,0.75 0,0.25 0.5,0.5";;
        5)  # morning star
            points="0,0 0.5,0.25 1,0 0.75,0.5 1,1 0.5,0.75 0,1 0.25,0.5";;
        6)  # small square
            points="0.33,0.33 0.67,0.33 0.67,0.67 0.33,0.67";;
        *)  # checkerboard
            points="0,0 0.33,0 0.33,0.33 0.66,0.33 0.67,0 1,0 1,0.33 0.67,0.33 0.67,0.67 1,0.67 1,1 0.67,1 0.67,0.67 0.33,0.67 0.33,1 0,1 0,0.67 0.33,0.67 0.33,0.33 0,0.33";;
    esac

    # create polygon with the applied ratio
    for point in $points; do
        polygon="$polygon $(echo "${point%%,*} * $spriteZCoord" | bc -l),$(echo "${point##*,} * $spriteZCoord" | bc -l)"
    done
    
    if [ "$points" != "" ]; then
        if [ "$fmt" = "svg" ]; then
            ret="<g transform=\"translate($((tX)), $((tY)))\">
                    <rect x=\"0\" y=\"0\" width=\"$spriteZCoord\" height=\"$spriteZCoord\" style=\"fill:$bRGB\" />
                    <path d=\"M $polygon Z\" style=\"fill:$fRGB\" />
                 </g>"
        else
            ret="push graphic-context
                    translate $((tX)),$((tY))
                    fill $bRGB      rectangle 0,0 $spriteZCoord,$spriteZCoord
                    fill $fRGB      path 'M $polygon Z'
                 pop graphic-context"
        fi
    else
        ret=""
    fi
}

# parse hash string
#
let csh=0x${hash:0:1}                       # corner sprite shape
let ssh=0x${hash:1:1}                       # side sprite shape
let xsh=0x${hash:2:1}; xsh=$((xsh & 7))     # center sprite shape


let cro=0x${hash:3:1}; cro=$((cro & 3))     # corner sprite rotation
let sro=0x${hash:4:1}; sro=$((sro & 3))     # side sprite rotation
let xbg=0x${hash:5:1}; xbg=$((xbg % 2))     # center sprite background

let cfr=0x${hash:6:2}                       # corner sprite foreground color
let cfg=0x${hash:8:2}
let cfb=0x${hash:10:2}

let sfr=0x${hash:12:2}                      # side sprite foreground color
let sfg=0x${hash:14:2}
let sfb=0x${hash:16:2}

#let angle=0x${hash:18:2}                    # final angle of rotation

# generate corner sprites
getsprite $csh "rgb($cfr,$cfg,$cfb)" $(((cro * 270) % 360)) 0 0
draw="$draw $ret"

getsprite $csh "rgb($cfr,$cfg,$cfb)" $(((cro * 270 + 90) % 360)) $((spriteZ * 2)) 0
draw="$draw $ret"

getsprite $csh "rgb($cfr,$cfg,$cfb)" $(((cro * 270 + 180) % 360)) $((spriteZ * 2)) $((spriteZ * 2))
draw="$draw $ret"

getsprite $csh "rgb($cfr,$cfg,$cfb)" $(((cro * 270 + 270) % 360)) 0 $((spriteZ * 2))
draw="$draw $ret"

# generate side sprites
getsprite $ssh "rgb($sfr,$sfg,$sfb)" $(((sro * 270) % 360)) $spriteZ 0
draw="$draw $ret"

getsprite $ssh "rgb($sfr,$sfg,$sfb)" $(((sro * 270 + 90) % 360)) $((spriteZ * 2)) $spriteZ
draw="$draw $ret"

getsprite $ssh "rgb($sfr,$sfg,$sfb)" $(((sro * 270 + 180) % 360)) $spriteZ $(($spriteZ * 2))
draw="$draw $ret"

getsprite $ssh "rgb($sfr,$sfg,$sfb)" $(((sro * 270 + 270) % 360)) 0 $spriteZ
draw="$draw $ret"

# generate center sprite
dr=$((cfr - sfr))
dg=$((cfg - sfg))
db=$((cfb - sfb))

if [[ $xbg -gt 0 && ( ${dr#-} -gt 127 || ${dg#-} -gt 127 || ${db#-} -gt 127 ) ]]; then
    # make sure there's enough contrast before we use background color of side sprite
    rgb="rgb($sfr,$sfg,$sfb)"
else
    rgb="rgb(255,255,255)"
fi

getcenter $xsh "rgb($cfr,$cfg,$cfb)" $rgb $spriteZ $spriteZ
draw="$draw $ret"

# generate identicon
#
if [ "$fmt" = "svg" ]; then
    if [ "$out" = "-" ]; then
        out="/dev/stdout"
    fi
    
    scale=$(echo "$size / $((spriteZ * 3))" | bc -l)
    
    draw="<g transform=\"scale($scale)\">$draw</g>"
    
    echo "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" viewbox=\"0 0 $size $size\" width=\"$size\" height=\"$size\">$draw</svg>" > $out
else
    convert -size $((spriteZ * 3))x$((spriteZ * 3)) xc:$back -fill none \
            -draw "$draw" \
            -swirl $swirl \
            -scale $size"x"$size \
            $fmt:$out
fi