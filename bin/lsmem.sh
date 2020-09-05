#!/usr/bin/env bash

if [[ $(uname) == 'Darwin' ]]; then
  ps -A -m -S -O comm,pmem,rss | awk '
    NR == 1 { print; next }
    { a[$2] += $3; b[$2] += $4; }
    END {
      for (i in a) {
        size_in_bytes = b[i] * 1024
        split("B KB MB GB TB PB", unit)
        human_readable = 0
        if (size_in_bytes == 0) {
          human_readable = 0
          j = 0
        }
        else {
          for (j = 5; human_readable < 1; j--)
            human_readable = size_in_bytes / (2^(10*j))
        }
        printf "%-20s\t%s\t%.2f%s\t%s\n", i, a[i], human_readable, unit[j+2], b[i]
      }
    }
  ' | awk 'NR>1' | sort -rnk4 | awk '
    BEGIN {printf "%-20s\t%%MEM\tSIZE\n", "COMMAND"}
    {
      printf "%-20s\t%s\t%s\n", $1, $2, $3
    }
  ' | less
else
  ps -A --sort -rss -o comm,pmem,rss | awk '
    NR == 1 { print; next }
    { a[$1] += $2; b[$1] += $3; }
    END {
      for (i in a) {
        size_in_bytes = b[i] * 1024
        split("B KB MB GB TB PB", unit)
        human_readable = 0
        if (size_in_bytes == 0) {
          human_readable = 0
          j = 0
        }
        else {
          for (j = 5; human_readable < 1; j--)
            human_readable = size_in_bytes / (2^(10*j))
        }
        printf "%-20s\t%s\t%.2f%s\t%s\n", i, a[i], human_readable, unit[j+2], b[i]
      }
    }
  ' | awk 'NR>1' | sort -rnk4 | awk '
    BEGIN {printf "%-20s\t%%MEM\tSIZE\n", "COMMAND"}
    {
      printf "%-20s\t%s\t%s\n", $1, $2, $3
    }
  ' | less
fi
