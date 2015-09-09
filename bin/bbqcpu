#! /bin/bash
CURRENT_CPU=`eval exec cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`

action=$(yad --width 300 --entry --title "LinuxBBQ Governor" \
    --image-on-top \
    --image=/usr/share/icons/bbqtux2.png \
    --button="APERF/MPERF:2" \
    --button="gtk-ok:0" --button="gtk-close:1" \
    --text "Current governor is $CURRENT_CPU." \
    --entry-text \
    "Conservative" "Powersave" "Ondemand" "Performance")
ret=$?

[[ $ret -eq 1 ]] && exit 0

if [[ $ret -eq 2 ]]; then
    x-terminal-emulator -e cpufreq-aperf &
    exit 0
fi


case $action in
    Conservative*) cmd="sudo x-terminal-emulator -e cpufreq-set -g conservative" ;;
    Powersave*) cmd="sudo x-terminal-emulator -e cpufreq-set -g powersave" ;;
    Ondemand*) cmd="sudo x-terminal-emulator-e sudo cpufreq-set -g ondemand" ;;
    Performance*) cmd="sudo x-terminal-emulator -e cpufreq-set -g performance" ;;
    *) exit 1 ;;        
esac

eval exec $cmd
exit 0

