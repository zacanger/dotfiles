#!/bin/sh

# Get active audio sink
active() {
  echo $(pactl list short | grep -i running | cut -f 1)
}

# set volume for current sink
volume() {
  pactl set-sink-volume $(active) -- $@
}

# Move input sinks to different audio sink
# move 2  # move all active inputs to sink 2
move() {
  active=$(pacmd list-sink-inputs | grep index | cut -d ":" -f 2)

  for input in $active; do
    pacmd move-sink-input $input $1
  done
}

main() {
  cmd=$1
  shift

  case $cmd in
    volume)
      volume $@
      ;;
    move)
      move $@
      ;;
    active)
      active $@
      ;;
  esac
}

main $@
