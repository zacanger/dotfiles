#!/bin/sh

#TODO: usage instructions

BAR_CHARS="${BAR_CHARS:-#-M-[]}"
SHOW_LEVEL="${SHOW_LEVEL:-yes}"
USE_MUTE_CHARS="${USE_MUTE_CHARS:-yes}"
BAR_WIDTH="${BAR_WIDTH:-10}"

c_on="$(echo $BAR_CHARS | cut -c1)"
c_off="$(echo $BAR_CHARS | cut -c2)"
c_mute_on="$(echo $BAR_CHARS | cut -c3)"
c_mute_off="$(echo $BAR_CHARS | cut -c4)"
c_start="$(echo $BAR_CHARS | cut -c5)"
c_end="$(echo $BAR_CHARS | cut -c6)"

volume="$(amixer sget Master,0 | grep '^\s*Mono' | awk '{print $4}' | sed 's_[^0-9A-Za-z ]__g')"
vol_width="$(( (${BAR_WIDTH} * ${volume}) / 100 ))"

if [ "$(amixer sget Master,0 | grep off | wc -l)" = "1" ] ; then
    mute="yes"
else
    mute="no"
fi

if [ "${mute}" = "yes" ] && [ "${USE_MUTE_CHARS}" = "yes" ] ; then
    c_on=${c_mute_on}
    c_off=${c_mute_off}
fi


echo -n "${c_start}"

for i in $(seq ${vol_width}) ; do
    echo -n "${c_on}"
done

for i in $(seq $(( ${BAR_WIDTH} - ${vol_width} ))) ; do
    echo -n "${c_off}"
done

echo -n "${c_end}"

if [ "${SHOW_LEVEL}" = "yes" ] ; then
    echo -n "${volume}"
    if [ "${mute}" = "yes" ] ; then
        echo -n "M"
    else
        echo -n "%"
    fi
fi
