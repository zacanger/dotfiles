vol() {
  info=$(amixer get Master)
  level=$(echo ${info} | tail -1 | sed 's/.*\[\([0-9]*%\)\].*/\1/')
  state=$(echo ${info} | tail -1 | sed 's/.*\[\(on\|off\)\].*/\1/')
  if [[ "$state" == "off" ]]; then
    echo -e "M"
  else
    echo -e "${level}"
  fi
}

