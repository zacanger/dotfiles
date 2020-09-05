#!/usr/bin/env bash

minutes="$1"
bell_path="$HOME/Dropbox/z/x/bell.mp3"
cols=$(tput cols)
rows=$(tput lines)
middle_row=$((rows / 2))
middle_col=$(((cols / 2) - 4))
sec=00
min="$minutes"

play_bell() {
  mplayer "$bell_path" > /dev/null 2>&1 &
}

end() {
  tput cvvis
  tput sgr0
  tput cup "$(tput lines)" 0
  tput cnorm
  exit 0
}

usage() {
  echo "usage: meditate.sh 60"
  echo "please provide a minutes duration"
  exit 1
}

validate() {
  re='^[0-9]+$'
  if [ -z "$min" ] || ! [[ "$min" =~ $re ]]; then
    usage
  fi
}

main() {
  validate

  tput clear
  play_bell
  tput bold
  tput civis

  while [ "$min" -ge 0 ]; do
    while [ $sec -ge 0 ]; do
      # play bell at every five minute mark
      rem=$(( min % 5 ))
      [ "$rem" -eq 0 ] && \
        [ "$sec" -eq 0 ] && \
        [ "$min" -ne "$minutes" ] && \
        play_bell

      # also play at one minute mark
      [ "$min" -eq 1 ] && \
        [ "$sec" -eq 0 ] && \
        [ "$min" -ne "$minutes" ] && \
        play_bell

      tput cup $middle_row $middle_col
      echo -ne "$(printf %02d:%02d "$min" $sec)\e"
      ((sec=sec-1))
      sleep 1
    done
    sec=59
    ((min=min-1))
  done
  echo -e "${RESET}"
  play_bell
end
}

trap end INT
main
