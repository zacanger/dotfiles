#!/bin/bash

pre=""

for i in\
  bin\
  sbin\
  lib\
  libexec\
  data\
  sysconf\
  sharedstate\
  localstate\
  lib\
  include\
  oldinclude\
  info\
  man; do

  pre="${pre} --${i}dir=${1}"

done

echo $pre
