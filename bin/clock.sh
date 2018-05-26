#!/usr/bin/env bash

BG_GREY="$(tput setab 8)"
FG_BLACK="$(tput setaf 0)"
FG_WHITE="$(tput setaf 7)"

terminal_size() {
  terminal_cols="$(tput cols)"
  terminal_rows="$(tput lines)"
}

banner_size() {
  # different versions of banner have different sizes
  banner_cols=0
  banner_rows=0

  while read; do
    [[ ${#REPLY} -gt $banner_cols ]] && banner_cols=${#REPLY}
    ((++banner_rows))
  done < <(banner "00:00")
}

display_clock() {
  local row=$clock_row

  while read; do
    tput cup $row $clock_col
    echo -n "$REPLY"
    ((++row))
  done < <(banner "$(date +'%H:%M ')")
}

# Set a trap to restore terminal on Ctrl-c (exit).
# Reset character attributes, make cursor visible, and restore
# previous screen contents (if possible).
trap 'tput sgr0; tput cnorm; tput rmcup || clear; exit 0' SIGINT

# Save screen contents and make cursor invisible
tput smcup; tput civis

# Calculate sizes and positions
terminal_size
banner_size
clock_row=$(((terminal_rows - banner_rows) / 2))
clock_col=$(((terminal_cols - banner_cols) / 2))
progress_row=$((clock_row + banner_rows + 1))
progress_col=$(((terminal_cols - 60) / 2))

# handle tmux or whatever
blank_screen=
for ((i=0; i < (terminal_cols * terminal_rows); ++i)); do
  blank_screen="${blank_screen} "
done

echo -n ${BG_GREY}${FG_WHITE}
while true; do
  if tput bce; then # Paint the screen the easy way if bce is supported
    clear
  else # Do it the hard way
    tput home
    echo -n "$blank_screen"
  fi
  tput cup $clock_row $clock_col
  display_clock

  # Draw a black progress bar then fill it in white
  tput cup $progress_row $progress_col
  echo -n ${FG_BLACK}
  echo -n "###########################################################"
  tput cup $progress_row $progress_col
  echo -n ${FG_WHITE}

  # Advance the progress bar every second until a minute is used up
  for ((i = $(date +%S);i < 60; ++i)); do
    echo -n "#"
    sleep 1
  done
done
