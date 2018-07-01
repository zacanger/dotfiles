cecho() {
  s="$2"
  BLACK="\033[0;30m"
  BLUE="\033[0;34m"
  GREEN="\033[0;32m"
  CYAN="\033[0;36m"
  RED="\033[0;31m"
  PURPLE="\033[0;35m"
  ORANGE="\033[0;33m"
  LGRAY="\033[0;37m"
  DGRAY="\033[1;30m"
  LBLUE="\033[1;34m"
  LGREEN="\033[1;32m"
  LCYAN="\033[1;36m"
  LRED="\033[1;31m"
  LPURPLE="\033[1;35m"
  YELLOW="\033[1;33m"
  WHITE="\033[1;37m"
  NORMAL="\033[m"

  color=\$${1:-NORMAL}

  echo -ne "$(eval echo ${color})"
  echo -ne $s
  echo -ne "${NORMAL}"
  echo
}
