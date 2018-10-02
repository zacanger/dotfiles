pad() {
  for (( i = 0; i < ${2:-0}; i++ )); do printf "${1:- }"; done
}
