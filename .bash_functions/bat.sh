bat() {
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

