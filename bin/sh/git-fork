#!/bin/sh

domain=$(git config remote.origin.url | cut -d/ -f3)
owner=$(git config remote.origin.url | cut -d/ -f4)
repo=$(git config remote.origin.url | cut -d/ -f5)
user=$(git config github.user)

test "$domain" != "github.com" && echo "not a github repo." && exit 1
test -z "$owner" && echo "unable to define repo owner." && exit 1
test -z "$repo" && echo "unable to define repo name." && exit 1
test -z "$user" && echo "username required." && exit 1

repo=${repo%.git}

echo "Forking $owner/$repo"
git hub api POST /repos/$owner/$repo/forks > /dev/null \
  && git remote add -f $user git@github.com:$user/$repo.git
