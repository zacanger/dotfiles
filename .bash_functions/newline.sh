newline() {
  stty sane &&
    local CSI='\033[' &&
    printf "${CSI}1;37;46m"'$'"${CSI}0m"      # EOL marker
  printf '\b\b\b''\b''\b\b\b\b\b\b\b\b\b' &&  # restore column position

  # CR -> LF ; inhibit if at left margin
  stty onocr ocrnl &&
    printf '\r' &&
    stty -onocr -ocrnl &&
    printf '\r'
}
