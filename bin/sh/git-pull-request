#!/bin/sh

_git_pull_request_usage(){
  echo "$0"
}

_git_pull_request_list(){
  repo_info=$(git config remote.origin.url | sed -rn 's/^.*(github.com).(.*)\/(.*)\.git/\1\t\2\t\3/p')
  domain=$(echo "$repo_info" | cut -f1)
  owner=$(echo "$repo_info" | cut -f2)
  repo=$(echo "$repo_info" | cut -f3)
  user=$(git config github.user)

  test "$domain" != "github.com" && echo "not a github repo" && exit 1
  test -z "$owner" && echo "unable to define repo owner" && exit 1
  test -z "$repo" && echo "unable to define repo name" && exit 1
  test -z "$user" && echo "username required" && exit 1

  columns=$(git config pull-request.list || echo "number state user.login created_at title")
  git hub api GET /repos/$owner/$repo/pulls "" "$columns"
}

_git_pull_request_show(){
  id=$1
  repo_info=$(git config remote.origin.url | sed -rn 's/^.*(github.com).(.*)\/(.*)\.git/\1\t\2\t\3/p')
  domain=$(echo "$repo_info" | cut -f1)
  owner=$(echo "$repo_info" | cut -f2)
  repo=$(echo "$repo_info" | cut -f3)
  user=$(git config github.user)

  test "$domain" != "github.com" && echo "not a github repo" && exit 1
  test -z "$owner" && echo "unable to define repo owner" && exit 1
  test -z "$repo" && echo "unable to define repo name" && exit 1
  test -z "$user" && echo "username required" && exit 1

  test -z "$id" && echo "pull request id required" && exit 1
  # TODO List commits on a pull request, List pull requests files
  git hub api GET /repos/$owner/$repo/pulls/$id
}

_git_pull_request_open(){
  repo_info=$(git config remote.origin.url | sed -rn 's/^.*(github.com).(.*)\/(.*)\.git/\1\t\2\t\3/p')
  domain=$(echo "$repo_info" | cut -f1)
  owner=$(echo "$repo_info" | cut -f2)
  repo=$(echo "$repo_info" | cut -f3)
  user=$(git config github.user)

  test "$domain" != "github.com" && echo "not a github repo" && exit 1
  test -z "$owner" && echo "unable to define repo owner" && exit 1
  test -z "$repo" && echo "unable to define repo name" && exit 1
  test -z "$user" && echo "username required" && exit 1

  current_head=$(git name-rev HEAD 2> /dev/null | cut -d" " -f2)

  base=$1
  head=${2-$current_head}
  title=$3
  message=$4

  test -z "$base" && echo "base required" && exit 1
  test -z "$head" && echo "head required" && exit 2

  PULLREQUEST_EDITMSG="$(git rev-parse --git-dir)/PULLREQUEST_EDITMSG"
  echo "$title\n\n$message" > $PULLREQUEST_EDITMSG
  $EDITOR $PULLREQUEST_EDITMSG

  title=$(head -1 $PULLREQUEST_EDITMSG)
  message=$(tail -n +3 $PULLREQUEST_EDITMSG)

  test -z "$title" && echo "title required" && exit 3

  body="{\"title\": \"$title\", \"body\": \"$message\", \"base\": \"$base\", \"head\": \"$head\"}"
  # TODO add issue option as alternative input to title/message
  # TODO request pull request for orginal repo: POST /repos/jwerlley/learn_python/pulls 
  # use `git hub api GET /repos/jweslley/learn_python  | gh-json parent` to get info from original repo
  git hub api POST /repos/$owner/$repo/pulls "$body"
}

_git_pull_request_close(){
  id=$1
  repo_info=$(git config remote.origin.url | sed -rn 's/^.*(github.com).(.*)\/(.*)\.git/\1\t\2\t\3/p')
  domain=$(echo "$repo_info" | cut -f1)
  owner=$(echo "$repo_info" | cut -f2)
  repo=$(echo "$repo_info" | cut -f3)
  user=$(git config github.user)

  test "$domain" != "github.com" && echo "not a github repo" && exit 1
  test -z "$owner" && echo "unable to define repo owner" && exit 1
  test -z "$repo" && echo "unable to define repo name" && exit 1
  test -z "$user" && echo "username required" && exit 1

  test -z "$id" && echo "pull request id required" && exit 1

  body="{\"state\": \"closed\", \"_method\": \"PATCH\"}"
  git hub api POST /repos/$owner/$repo/pulls/$id "$body" > /dev/null && echo "pull request #$id was closed"
}

_git_pull_request_merge(){
  id=$1
  message=$2

  repo_info=$(git config remote.origin.url | sed -rn 's/^.*(github.com).(.*)\/(.*)\.git/\1\t\2\t\3/p')
  domain=$(echo "$repo_info" | cut -f1)
  owner=$(echo "$repo_info" | cut -f2)
  repo=$(echo "$repo_info" | cut -f3)
  user=$(git config github.user)

  test "$domain" != "github.com" && echo "not a github repo" && exit 1
  test -z "$owner" && echo "unable to define repo owner" && exit 1
  test -z "$repo" && echo "unable to define repo name" && exit 1
  test -z "$user" && echo "username required" && exit 1
  test -z "$id" && echo "pull request id required" && exit 1

  body="{\"_method\": \"PUT\", \"commit_message\": \"$message\"}"
  # TODO verify if mergeable == true
  # FIXME not found?! how merge this?
  git hub api POST /repos/$owner/$repo/pulls/$id/merge "$body" > /dev/null && echo "pull request #$id was merged"
}

_git_pull_request_apply(){
  id=$1

  repo_info=$(git config remote.origin.url | sed -rn 's/^.*(github.com).(.*)\/(.*)\.git/\1\t\2\t\3/p')
  domain=$(echo "$repo_info" | cut -f1)
  owner=$(echo "$repo_info" | cut -f2)
  repo=$(echo "$repo_info" | cut -f3)
  user=$(git config github.user)

  test "$domain" != "github.com" && echo "not a github repo" && exit 1
  test -z "$owner" && echo "unable to define repo owner" && exit 1
  test -z "$repo" && echo "unable to define repo name" && exit 1
  test -z "$user" && echo "username required" && exit 1
  test -z "$id" && echo "pull request id required" && exit 1

  url="https://github.com/$owner/$repo/pull/$id.patch"
  echo "applying pull request #$id"
  curl -sS $url | git am --signoff
}

test $# -eq 0 && _git_pull_request_list && exit

subcommand=$1
shift
case $subcommand in
  open) _git_pull_request_open $* ;;
  close) _git_pull_request_close $* ;;
  merge) _git_pull_request_merge $* ;;
  apply) _git_pull_request_apply $* ;;
  # TODO branch) _git_pull_request_branch $* ;;
  # TODO reopen) _git_pull_request_reopen $* ;;
  show) _git_pull_request_show $* ;;
  *) _git_pull_request_usage ;;
esac
