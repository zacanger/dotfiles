#!/bin/bash

if [ "$1" == "-l" ]; then
  echo "$(w && sensors && cat /proc/cpuinfo && iostat)"
else
  echo "$(w && sensors | grep "Core" && cat /proc/cpuinfo | grep "cpu MHz" && iostat | grep "Device" -A 1)"
fi

