#!/usr/bin/env bash

# Copyright (c) 2010 Tapio Vierros | gh:tapio/vcs | zlib license
# script to abstract some vcs tasks

if [ "$1" = "--help" -o "$1" = "-h" -o "$1" = "" ]; then
  echo "Usage: `basename $0` command [repository_path1] [repository_path2] [...]"
  echo
  echo "Commands:"
  echo "up | update | pull   - Fetch upstream changes"
  echo "log                  - Print log messages to pager"
  echo "diff                 - Show diff of current changes"
  echo "show                 - Show diff of HEAD commit"
  echo
  echo "If no repository is given, current directory is assumed."
  echo "Updating is done asynchronously (all given repos at the same time)."
  echo "Currently supported VCS: Git, Mercurial, Subversion, Bazaar (partial)"
  exit 0
fi

# validate command
cmd="$1"
echo "up update pull log show diff" | grep "$cmd" >/dev/null
if [ $? -ne 0 ]; then
  echo "Unknown command '$cmd'."
  echo "Type '`basename $0` --help' for instructions."
  exit 1
fi
shift

# if no directory
DIRS="$@"
if [ ! "$DIRS" ]; then
  DIRS=.
fi

# this could be rewritten. so much duplication.
commands_git(){
  if [ $1 = "up" -o $1 = "update" -o $1 = "pull" ]; then
    git pull &
  elif [ $1 = "log" ]; then
    git log
  elif [ $1 = "show" ]; then
    git show
  elif [ $1 = "diff" ]; then
    git diff
  fi
}

commands_svn(){
  if [ $1 = "up" -o $1 = "update" -o $1 = "pull" ]; then
    svn up &
  elif [ $1 = "log" ]; then
    svn log -l50 | less
  elif [ $1 = "show" ]; then
    echo "TODO: 'svn show'"
  elif [ $1 = "diff" ]; then
    svn diff | less
  fi
}

commands_hg(){
  if [ $1 = "up" -o $1 = "update" -o $1 = "pull" ]; then
    hg pull && hg update &
  elif [ $1 = "log" ]; then
    hg log -l50 | less
  elif [ $1 = "show" ]; then
    echo "TODO: 'hg show'"
  elif [ $1 = "diff" ]; then
    hg diff | less
  fi
}

commands_bzr(){
  if [ $1 = "up" -o $1 = "update" -o $1 = "pull" ]; then
    bzr pull &
  elif [ $1 = "log" ]; then
    bzr log -50 | less
  elif [ $1 = "show" ]; then
    echo "TODO: 'bzr show'"
  elif [ $1 = "diff" ]; then
    bzr diff | less
  fi
}

# loop thru dirs
for i in $DIRS; do
  echo -n "$i - $cmd"
  # check if exists
  if [ ! -d "$i" ]; then
    echo ": No such directory."
  else
    ( cd "$i"
    # which vcs?
    found_repo=""
    for v in svn git hg bzr; do
      if [ -d ".$v" ]; then
        found_repo=1
        echo " ($v)"
        commands_$v $cmd
        break
      fi
    done
    if [ ! "$found_repo" ]; then
      echo ": No repository found."
    fi
    )
  fi
done

# notify when done
while [ 1 ]; do
  ps | grep -E "git|svn|bzr|hg" >/dev/null
  if [ $? -ne 0 ]; then
    echo "All done."
    exit 0
  fi
  sleep 1
done

