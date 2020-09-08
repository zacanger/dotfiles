#!/usr/bin/env bash
set -e

main_menu() {
  echo '1) Celsius to Fahrenheit'
  echo '2) Fahrenheit to Celsius'
  echo ""
  read -rp "Please choose one of the options above: " option
  case $option in
    1) c_to_f
      ;;
    2) f_to_c
      ;;
    *) echo "Invalid choice!"; exit 1
      ;;
  esac
}

f_to_c() {
  echo "Fahrenheit to Celsius Conversion"
  read -rp "Enter the temperature (in Fahrenheit): " f_temp
  tconv=$(echo "($f_temp - 32) * 5 / 9 " | bc)
  echo -en "The Temperature in Celsius is "
  echo "$tconv"
  exit 0
}

c_to_f() {
  echo "Celsius to Fahrenheit Conversion"
  read -rp "Enter the temperature (in Celsius): " c_temp
  tconv=$(echo "$c_temp * 9 / 5 + 32 " | bc)
  echo -en "The Temperature in Fahrenheit is "
  echo "$tconv"
  exit 0
}

main_menu
