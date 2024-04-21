#!/usr/bin/env bash
set -e

echo_if_not_empty() {
    if [[ -n $2 ]]; then
        echo "$1: $2"
    fi
}

while true; do
    batt=$(bs.sh)
    disk=$(df -h / | awk '{print $4}' | tail -1)
    datestring=$(date +"%a %Y-%m-%d %H:%M")
    if [[ $(uname) == 'Darwin' ]]; then
        cpuusage=$(ps -A -o %cpu | awk '{ cpu += $1;  } END { print cpu  }')
        temperature="" # no easy equivalent of `sensors`
        dropbox="" # no cli on mac

    else
        cpuusage=$(mpstat |
            awk '$3 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $3 ~ /all/ { printf("%d%%",100 - $field) }')
        temperature=$(sensors -f |
            grep Core |
            tr -s ' ' |
            cut -d' ' -f 3 |
            sed 's/[^0-9.]*//g' |
            awk '{ total += $1; count++ } END { print total/count }'
        )
        dropbox=$(dropbox status | head -1)

    fi

    echo "$datestring"
    echo_if_not_empty cpu "$cpuusage"
    echo_if_not_empty temp "$temperature"
    echo_if_not_empty batt "$batt"
    echo_if_not_empty disk "$disk"
    echo_if_not_empty db "$dropbox"
    sleep 60
    clear
done
