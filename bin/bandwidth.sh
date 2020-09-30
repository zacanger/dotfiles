#!/usr/bin/env bash
set -e

# Monitor current bandwidth usage by watching /proc/net/dev
# Yoinked from https://github.com/whiteinge/dotfiles/

interval="5"

printf '\e[s' # save cur pos
while
  cp -f /proc/net/dev /tmp/net-dev-old
  sleep "$interval"
do
  printf '\e[u' # restore cur pos
  date
  awk -v interval="$interval" '
    $1 ~ "lo:" { next }
    $1 ~ ":$" {
      if (NR == FNR) {
        o_recv[$1] = $2; o_send[$1] = $10
      } else {
        n_recv[$1] = $2; n_send[$1] = $10
      }
    }
    END {
      printf("%-25s %-15s %-15s\n", "iface", "recv (KB/s)", "send (KB/s)")
      for (i in o_recv) {
        recv = (n_recv[i] - o_recv[i]) / interval / 1024
        send = (n_send[i] - o_send[i]) / interval / 1024
        printf("%-25s %-15.1f %-15.1f\n", i, recv, send)
      }
    }
  ' /tmp/net-dev-old /proc/net/dev
done
