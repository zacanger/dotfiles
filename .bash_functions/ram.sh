ram() {
  s=$(free --mega | awk '/Mem:/ { print $2 } /buffers\/cache/ { print $3 }')
  echo -e "${s}"
}

