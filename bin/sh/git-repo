#!/bin/bash

_git_repo_usage(){
  echo ""
}

_git_repo_list(){
  type=${1-all}

  body="{\"type\": \"$type\"}"
  columns=$(git config repo.list || echo "name description")
  git hub api GET /user/repos "$body" "$columns"
}

_git_repo_create(){
  homepage=""
  description=""
  private=$(git config repo.create.private || echo "false")
  has_issues=$(git config repo.create.issues || echo "true")
  has_wiki=$(git config repo.create.wiki || echo "true")
  has_downloads=$(git config repo.create.downloads || echo "true")

  while getopts "pPiIwWdDh:e:" option; do
    case "$option" in
      p) private="true"; shift;;
      P) private="false"; shift;;
      i) has_issues="true"; shift;;
      I) has_issues="false"; shift;;
      w) has_wiki="true"; shift;;
      W) has_wiki="false"; shift;;
      d) has_downloads="true"; shift;;
      D) has_downloads="false"; shift;;
      e) description="$OPTARG"; shift;shift;;
      h) homepage="$OPTARG"; shift;shift;;
    esac
  done

  name="$1"

  # repo's name is based on current dir name if it already is a git dir
  toplevel=$(git rev-parse --show-toplevel 2> /dev/null)
  if [ ! -z "$toplevel" ]; then
    if [ -z "$name" ]; then
      name=$(basename "$toplevel")
    fi
    user=$(git config github.user)
    test -z "$user" && echo "username required." && exit 1
  fi

  test -z "$name" && echo "name required" && exit 1

  # FIXME cannot send private=false \"homepage\": \"$homepage\",  \"private\": \"$private\",      \
  body="{\"name\": \"$name\", \"description\": \"$description\",  \
    \"homepage\": \"$homepage\",      \
    \"has_issues\": \"$has_issues\", \"has_wiki\": \"$has_wiki\", \
    \"has_downloads\": \"$has_downloads\"}"

  # TODO add option to remote name
  # TODO add option to push another branch, not just master
  # TODO push the current branch by default, not master
  git hub api POST /user/repos "$body" > /dev/null              \
    && git remote add -f origin git@github.com:$user/$name.git \
    && git push -u origin master                               \
    && echo "$name repository was created"
}

_git_repo_clone(){
  info="$1"; shift

  if [[ -z `echo "$info" | grep -v /` ]]; then
    user=$(echo "$info" | cut -d/ -f1)
    repo=$(echo "$info" | cut -d/ -f2)
    url="git://github.com/$user/$repo.git"
  else
    user=$(git config github.user)
    repo="$info"
    url="git@github.com:$user/$repo.git"
  fi

  test -z "$user" && echo "username required." && exit 1
  test -z "$repo" && echo "repo name required." && exit 2

  git clone $url "$@"
}

test $# -eq 0 && _git_repo_list && exit

subcommand=$1
shift
case $subcommand in
  create) _git_repo_create "$@" ;;
  clone) _git_repo_clone "$@" ;;
  list) _git_repo_list "$@" ;;
  *) _git_repo_usage ;;
esac
