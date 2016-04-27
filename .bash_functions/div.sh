div() {
  local LINE=''
  while (( ${#LINE} < "$(tput cols)" ))
  do
    LINE="$LINE-"
  done
  echo "${LINE}"
}

