#!/usr/bin/env bash

# read in the github username/repository
echo "What's the GitHub repo?\nformat: username/repository"
read repo

gh="https://github.com/$repo"

# clone the repo into local username/repository
git clone "$gh" "$repo"

cd $repo

# remove old repo metadata
rm -rf .git

# new repo here!
git init
git add -A && git commit -am "Initial commit."

echo "Please go to https://github.com/new"

echo "What's your remote repo's url?"
read remote

# push the new stuff up
echo "Pushing your local repo to GitHub!"
git remote add origin "$remote"
git push -u origin master

git status -sb

echo

for opener in xdg-open open cygstart "start"; {
  if command -v $opener; then
    open=$opener;
    break;
  fi
}

$open $url || echo "unknown opener; open manually!\n"

