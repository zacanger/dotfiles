#!/usr/bin/env bash

mainmenu () {
  clear; echo "Temp Conversion Script";echo ""; menu="\t1) \tFahrenheit to Celsius Conversion\n\t2)\tCelsius to Fahrenheit Conversion\n\t0)\tExit";
  echo -e "$menu";echo "";read -p "Please choose one of the options above : " option
  while true; do
     case $option in
        1)   F2C;
           ;;
        2)   C2F;
           ;;
        0)   option="";
           exit;
           ;;
        *)   echo "That choice was invalid!!";
           ;;
     esac
  done
}

F2C () {
  echo "Fahrenheit to Celsius Conversion";echo "Enter the temperature (in Fahrenheit):";read FT
  tconv=`echo "($FT - 32) * 5 / 9 " |bc`
  echo -en "The Temperature in Celsius is ";echo "$tconv" ;read -p "Hit RETURN to continue" temp;mainmenu
}

C2F () {
  echo "Celsius to Fahrenheit Conversion";echo "Enter the temperature (in Celsius):";read CT
  tconv=`echo "$CT * 9 / 5 + 32 " |bc`
  echo -en "The Temperature in Fahrenheit is ";echo "$tconv";read -p "Hit RETURN to continue" temp;mainmenu
}

mainmenu
exit