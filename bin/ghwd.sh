#!/usr/bin/env bash

# ISC, gh:zeke/ghwd
# don't need this NPM installed, so i'm just throwing it in my ~/bin/sh
# opens github/bitbucket/gitlab page that matches cwd/branch

# Figure out github repo base URL
base_url=$(git config --get remote.origin.url)
base_url=${base_url%\.git} # remove .git from end of string

# Fix git@github.com: URLs
base_url=${base_url//git@github\.com:/https:\/\/github\.com\/}

# Fix git://github.com URLS
base_url=${base_url//git:\/\/github\.com/https:\/\/github\.com\/}

# Fix git@bitbucket.org: URLs
base_url=${base_url//git@bitbucket.org:/https:\/\/bitbucket\.org\/}

# Fix git@gitlab.com: URLs
base_url=${base_url//git@gitlab\.com:/https:\/\/gitlab\.com\/}

# Validate that this directory is a git directory
git branch 2>/dev/null 1>&2
if [ $? -ne 0 ]; then
  echo Not a git repo!
  exit $?
fi

# Find current directory relative to .git parent
full_path=$(pwd)
git_base_path=$(cd ./$(git rev-parse --show-cdup); pwd)
relative_path=${full_path#$git_base_path} # remove leading git_base_path from working directory

# If filename argument is present, append it
if [ "$1" ]; then
  relative_path="$relative_path/$1"
fi

# Figure out current git branch
# git_where=$(command git symbolic-ref -q HEAD || command git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null
git_where=$(command git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null

# Remove cruft from branchname
branch=${git_where#refs\/heads\/}

[[ $base_url == *bitbucket* ]] && tree="src" || tree="tree"
url="$base_url/$tree/$branch$relative_path"

echo $url

if [ "$(uname)" == "Darwin" ]; then
  /usr/bin/open $url
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  `which xdg-open` $url
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
  echo "get a real computer"
fi
