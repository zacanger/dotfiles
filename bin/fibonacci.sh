#!/usr/bin/env bash

a=0
b=1

for (( n=1; $n<=16; n=$n+1 ));
do
  a=$(($a + $b))
  echo -n "$a, "
  b=$(($a - $b))
done
echo "..."

