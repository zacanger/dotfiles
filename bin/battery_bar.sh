#!/bin/sh

#TODO: usage instructions

BAR_CHARS="${BAR_CHARS:->-<-[]}"
SHOW_LEVEL="${SHOW_LEVEL:-yes}"
BAR_WIDTH="${BAR_WIDTH:-10}"

c_charge_on="$(echo $BAR_CHARS | cut -c1)"
c_charge_off="$(echo $BAR_CHARS | cut -c2)"
c_discharge_on="$(echo $BAR_CHARS | cut -c3)"
c_discharge_off="$(echo $BAR_CHARS | cut -c4)"
c_start="$(echo $BAR_CHARS | cut -c5)"
c_end="$(echo $BAR_CHARS | cut -c6)"

charge="$(acpi | awk '{print $4}' | tr -d ,%)"
charge_width="$(( (${BAR_WIDTH} * ${charge}) / 100 ))"

if [ "$(acpi | grep Discharging | wc -l)" = "1" ] ; then
    discharging="yes"
else
    discharging="no"
fi

if [ "${discharging}" = "yes" ] ; then
    c_on=${c_discharge_on}
    c_off=${c_discharge_off}
else
    c_on=${c_charge_on}
    c_off=${c_charge_off}
fi


echo -n "${c_start}"

for i in $(seq ${charge_width}) ; do
    echo -n "${c_on}"
done

for i in $(seq $(( ${BAR_WIDTH} - ${charge_width} ))) ; do
    echo -n "${c_off}"
done

echo -n "${c_end}"

if [ "${SHOW_LEVEL}" = "yes" ] ; then
    echo -n "${charge}%"
fi
