#!/usr/bin/env bash

factorial() {
  local num=$1;
  if [ $num = 0 ]; then
    echo 1
    return ;
  fi ;
  echo $(( $num * $(factorial $(( $num - 1 )) ) ))
}

for ((n = 0; n <= 16; n++))
do
  echo "$n! = " $(factorial $(($n)))
done

