#!/bin/bash

# simple screen information script
# similar to archey and screenfetch without annoying ASCII graphics

# this script is provided with NO GUARANTEE and NO SUPPORT 
# if it breaks or does not do what you want, FIX IT YOURSELF

# wm array -- add any that need to be recognized
wms=( herbstluftwm i3 blackbox kwin awesome spectrwm matwm2 wmfs karmen fvwm cwm sithwm ratpoison evilwm xfwm4 openbox fluxbox pekwm)

# define colors for color-echo
red="\e[31m"
grn="\e[32m"
ylw="\e[33m"
cyn="\e[36m"
blu="\e[34m"
prp="\e[35m"
rst="\e[0m"    

TMP=$(mktemp)    # make temp file

color-echo() {  # print with colors
    echo -e $cyn$1': '$rst$2
}

print-kernel() {
    color-echo 'Kernel' "$(uname -smr)"
}

print-uptime() {
    up=$(</proc/uptime)
    up=${up//.*}                # string before first . is seconds
    days=$((${up}/86400))       # seconds divided by 86400 is days
    hours=$((${up}/3600%24))    # seconds divided by 3600 mod 24 is hours
    mins=$((${up}/60%60))       # seconds divided by 60 mod 60 is mins
    color-echo "Uptime" "$days"'d '"$hours"'h '"$mins"'m'
}

print-shell() {
    color-echo 'Shell' $SHELL
}

print-cpu() {
    arm=$(grep ARM /proc/cpuinfo)    # ARM procinfo uses different format
    if [ "$arm" != "" ]; then
        cpu=$(grep -m1 -i 'Processor' /proc/cpuinfo)
    else
        cpu=$(grep -m1 -i 'model name' /proc/cpuinfo)
    fi    
    color-echo 'CPU' "${cpu#*: }" # everything after colon is processor name
}

print-disk() {
    df -h / > $TMP
    total=$(awk 'NR==2 { print $2 }' $TMP) # field 2 on line 2 is total
    used=$(awk 'NR==2 { print $3 }' $TMP)  # field 3 on line 2 is used
    color-echo 'Disk' "$used / $total"
}

print-mem() {
    free -h > $TMP
    total=$(awk 'NR==2 { print $2 }' $TMP)   # field 2 on line 2 is total
    used=$(awk 'NR==3 { print $3 }' $TMP)    # field 3 on line 3 is used
    color-echo 'Mem' "$used / $total"
}

print-wm() {
    for wm in ${wms[@]}; do          # pgrep through wmname array
        pid=$(pgrep -u $USER $wm)    # if found, this wmname has running process
        if [ "$pid" ]; then
            color-echo 'WM' $wm
        fi
    done
}

print-de() {
    if [ $(pgrep -u $USER lxsession) ]; then         # if lxsession is running, assume LXDE
        color-echo 'DE' 'LXDE'
    elif [ $(pgrep -u $USER xfce4-session) ]; then   # if xfce4-session is running, assume Xfce
        color-echo 'DE' 'Xfce'
    fi
}

print-distro() {
    [[ -e /etc/os-release ]] && source /etc/os-release
    if [ -n "$PRETTY_NAME" ]; then
        color-echo 'OS' "$PRETTY_NAME"
    else
        color-echo 'OS' "not found"
    fi
}

print-colors() {
    NAMES=('black' 'red' 'green' 'yellow' 'blue' 'magenta' 'cyan' 'white')
    for f in $(seq 0 7); do
        echo -en "\033[m\033[$(($f+30))m ${NAMES[$f]} " # normal colors
    done
    echo	
    for f in $(seq 0 7); do
        echo -en "\033[m\033[1;$(($f+30))m ${NAMES[$f]} " # bold colors
    done
    echo -e "$rst\n"
}

echo -e '\n'$prp$USER'@'$HOSTNAME$rst'\n'   # print user and host name
print-distro
print-uptime
print-shell
print-de
print-wm
print-disk
print-mem
print-kernel
print-cpu
echo
print-colors

rm $TMP     # delete temp file
