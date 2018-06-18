# also set setupcolours
getcolour() {
  [[ $1 ]] && eval echo "\$_$(toupper $*)"
}
