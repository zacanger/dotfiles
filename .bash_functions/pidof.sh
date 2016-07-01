# finds pids for the (single) arg passed
# because os x doesn't have pidof
# which is fucking stupid

pidof() {
  ps -ef | grep -i "$1" | grep -v grep | awk '{print $2}'
}

