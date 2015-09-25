#!/bin/bash
# 

if [ $# -lt 1 ]
then
  echo "Useage: $0 <github username>"
  exit
fi

dir="githubBackup"
user="$1"
mkdir -p "$dir/$user"
cd "$dir/$user" 

clear
echo "Backing up all github projects for $user..."
sleep 2

# wget "https://github.com/$user?tab=repositories" -q -O-|\
#  grep "href"|\
#  grep "$user"|\
#  grep "Forks"|\
#  cut -d\" -f4|\
#  cut -d\/ -f3|while read line;
#  do
#      git clone "https://github.com/$user/${line}.git"
#  done


wget "https://github.com/$user?tab=repositories" -O -|\
  grep "repo-list-name" -A1|\
  grep 'href'|cut -d\" -f2|\
  while read url
  do 
    git clone "https://github.com${url}.git"
  done

clear
echo "${user}'s projects backed up to $(pwd)."
