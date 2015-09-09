#!/bin/bash

dir="debs"

if [ "$#" -lt 1 ]
then
  echo "usage: $0 <package>"
  exit
fi

mkdir -p "$dir"
cd "$dir"

#get packages
deps="$(apt-cache depends $1|grep "Depends:"|awk '{print $2}'|tr '\n' ' ')"
apt-get --print-uris --reinstall --yes install $1 $deps| grep ^\' | cut -d\' -f2|
while read url
do
  wget -c "$url"
done

#extract packages
for i in *.deb;
do
  ar vx "$i"
  tar xzvf data.tar.gz
  tar xJvf data.tar.xz
  rm data.tar.* control.tar.gz debian-binary $i 
done