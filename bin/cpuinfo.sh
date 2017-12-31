#!/usr/bin/env bash

declare -i cpuFreq
cpuFreq=$(cat /proc/cpuinfo | "cpu MHz" | sed 's/\ \ */ /g' | cut -f3 -d" " | cut -f1 -d".")
if [ $cpuFreq -ge 1000 ]
then
  cpu=$(echo $cpuFreq | cut -c1).$(echo $cpuFreq | cut -c2)GHz
else
  cpu=${cpuFreq}MHz
fi
echo " $(cat /proc/acpi/thermal_zone/THM/temperature | sed 's/\ \ */ /g' | cut -f2 -d" ")"
echo "Freq: "$cpu" "
