# finds pids for the (single) arg passed

findpids() {
  ps -ef | grep -i "$1" | grep -v grep | awk '{print $2}'
}

