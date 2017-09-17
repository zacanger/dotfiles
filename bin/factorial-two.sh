#!/usr/bin/env bash

f=1

for (( n=1; $n<=17; $((n++)) ));
do
  echo "$((n-1))! = $f"
  f=$((f*n))
done

