#!/bin/bash

# usage
if [[ "$1" == "help" ]]; then
    echo "Usage: $0 {datetime|vol|bat|wifi|ram|cpu|hdd|pac}"
    exit 0
fi


# colors
reset='\x1b[0m'
redbg='\033[48;5;196m' #octal
blkfg='\e[0;30m' # Black
redfg='\e[0;31m' # Red
grnfg='\e[0;32m' # Green
ylwfg='\e[0;33m' # Yellow
blufg='\e[0;34m' # Blue
purfg='\e[0;35m' # Purple
cynfg='\e[0;36m' # Cyan
whtfg='\e[0;37m' # White


# methods

datetime(){
    s=$(date "+%d %b %R")
    echo -e "${s}"
}

vol(){
    info=$(amixer get Master)
    level=$(echo ${info} | tail -1 | sed 's/.*\[\([0-9]*%\)\].*/\1/')
    state=$(echo ${info} | tail -1 | sed 's/.*\[\(on\|off\)\].*/\1/')

    if [[ "$state" == "off" ]]; then
        echo -e "M"
    else
        echo -e "${level}"
    fi
}

bat(){
    acpi=`acpi -b`
    regex='Battery [0-9]: (.+), (.+)%, (.+) (remaining)?'
    [[ $acpi =~ $regex ]]

    state="${BASH_REMATCH[1]}"
    pow="${BASH_REMATCH[2]}"
    time="${BASH_REMATCH[3]}"

    bat=""
    c=""
    if [[ $state == "Discharging" ]]; then
        if (( $pow < 10 )); then
            c="${redbg}"
        elif (( $pow < 25 )); then
            c="${redfg}"
        fi

        bat="-${pow}% (${time})"
    else
        bat="+${pow}%"
    fi

    echo -e "${bat}"
}

wifi(){
    iw=`iwconfig`
    regex='ESSID:"(.+)".*Quality=(.*)\/'
    [[ $iw =~ $regex ]]

    essid="${BASH_REMATCH[1]}"
    qual="${BASH_REMATCH[2]}"
    s=""

    if [[ $essid == "" ]]; then
        s="off/any"
    else
        s="${essid} ${qual}"
    fi

    echo -e "${s}"
}

ram(){
    s=$(free -m |awk '/cache:/ { print $3"M" }')
    echo -e "${s}"
}

cpu(){
    read cpu a b c previdle rest < /proc/stat
    prevtotal=$((a+b+c+previdle))

    sleep 0.5

    read cpu a b c idle rest < /proc/stat
    total=$((a+b+c+idle))
    cpu="$((100*( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))"

    echo -e "${cpu}%"
}

hdd(){
    hd=$(df | grep -Eo "([0-9]{,3}%) /$")
    echo -e "${hd% /*}"
}

pac(){
    pup="$(pacman -Qqu --dbpath /tmp/checkup-db-jason/ | wc -l)"
    echo -en "${pup}"
}


# run

eval "$1"
