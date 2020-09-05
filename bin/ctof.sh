#!/usr/bin/env bash

main_menu() {
  echo '1) Fahrenheit to Celsius'
  echo '2) Celsius to Fahrenheit'
  echo ""
  read -rp "Please choose one of the options above: " option
  case $option in
    1) F2C;
      ;;
    2) C2F
      ;;
    *) echo "Invalid choice!"; exit 1
      ;;
  esac
}

F2C() {
  echo "Fahrenheit to Celsius Conversion"
  read -rp "Enter the temperature (in Fahrenheit): " FT
  tconv=$(echo "($FT - 32) * 5 / 9 " | bc)
  echo -en "The Temperature in Celsius is "
  echo "$tconv"
  exit 0
}

C2F() {
  echo "Celsius to Fahrenheit Conversion"
  read -rp "Enter the temperature (in Celsius): " CT
  tconv=$(echo "$CT * 9 / 5 + 32 " | bc)
  echo -en "The Temperature in Fahrenheit is "
  echo "$tconv"
  exit 0
}

main_menu
