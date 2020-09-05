#!/usr/bin/env bash

if [ "$1" != "-y" ]; then
  echo "Make sure you replace the values in this script first"
  echo "and then run with the -y flag."
  exit 1
fi

git filter-branch --env-filter '

OLD_EMAIL="previous@email.com"
CORRECT_NAME="the right name"
CORRECT_EMAIL="new@email.com"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
export GIT_COMMITTER_NAME="$CORRECT_NAME"
export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
export GIT_AUTHOR_NAME="$CORRECT_NAME"
export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags

git push --force --tags origin 'refs/heads/*'
