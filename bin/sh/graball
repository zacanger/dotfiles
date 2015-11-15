#!/bin/bash

cwd=`pwd`

dorepo() {
  repo=$1
  basename=`basename $repo`
  dirname=.`dirname $repo`
  [ -e $dirname ] || mkdir $dirname
  if [ -e .$repo ]; then
    echo "skipping $repo"
    cd .$repo
    # git pull
    cd $cwd
  else
    git clone https://github.com$repo .$repo
  fi
}

gitsearch() {
  for page in `seq 50 60`; do
    for lang in Shell c Objective-C bash ruby cpp css php unknown python javascript ruby bash c; do
    repo_list=`curl 'https://github.com/search?l='$lang'&o=desc&p='$page'&q=stars%3A%3E1&s=forks&type=Repositories' | grep -A 1 repo-list-name | grep href | awk -F \" ' { print $2 } ' ` 
      sleep 4
      for repo in $repo_list; do
        dorepo $repo
      done
    done
  done
}

gitprojects() {
  for range in daily weekly monthly; do
    for lang in bash ruby cpp css php unknown python javascript ruby bash c; do
      repo_list=`curl 'https://github.com/trending?l='$lang'&since='$range | grep -A 1 repo-list-name | grep href | awk -F \" ' { print $2 } ' ` 
      for repo in $repo_list; do
        dorepo $repo
      done
    done
  done
}

gitauthors() {
  [ -e compare ] || mkdir compare
  for project in */*; do
    stat=`echo $project | tr '/' '_'`
    if [ -d $project -a ! -s $cwd/compare/$stat ]; then 
      echo $project
      cd $project
      git log --format='%aE' | sort -u | tr 'A-Z' 'a-z' > $cwd/compare/$stat
      cd $cwd
    fi
  done
}

gitsearch
#gitprojects
gitauthors
cd compare
cat * | sort | uniq -c | sort -n


