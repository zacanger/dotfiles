#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Useage: $0 <user>"
	echo "Example: $0 metalx1000"
	exit 0
fi

user=$1

wget "https://github.com/metalx1000?tab=repositories" -q -O-|\
    grep "href"|\
    grep "$user"|\
    grep "Forks"|\
    cut -d\" -f4|\
    cut -d\/ -f3|while read line;
    do
        git clone "https://github.com/$user/${line}.git"
    done