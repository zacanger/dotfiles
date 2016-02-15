#!/bin/bash

__git_hub_tabulate(){
  attrs="$*"
  sep=""

  columnCount=$(echo $attrs | wc -w)
  sedglue=$(yes "N;" | head -$((columnCount - 1)) | xargs -i printf {})
  header=$(echo $attrs | tr " " "$sep")
  table=$(gh-json $attrs | sed -e "$sedglue;s/\n/$sep/g")
  if [ ! -z "$table" ] ; then
    echo "$(echo "$header"; echo "$table")" | column -t -s"$sep"
  fi
}

_git_hub_api(){
  test $# -eq 0 && curl -i https://api.github.com && exit

  method="$1"
  url="$2"
  body="$3"
  columns="$4"
  token=$(git hub oauth)

  test -z "$method" && echo "http method required" 1>&2 && exit 42
  test -z "$(echo -e "GET\nPOST\nDELETE" | grep "^$method$")" && echo "invalid http method" 1>&2 && exit 43
  test -z "$url" && echo "url required" 1>&2 && exit 42
  test -z "$token" && echo "access token required." 1>&2 && exit 42

  response=$(curl -sSX $method https://api.github.com$url \
                        -H "Authorization: token $token"  \
                        -d "$body" --write-out "%{http_code}")

  json=`echo $response | sed 's/...$//'`
  http_code=`echo -e "$response" | tail -1`

  if [ "${http_code:0:1}" == "2" ] ; then
    if [ -z "$columns" ] ; then
      printf "$json"
    else
      printf "$json" | __git_hub_tabulate "$columns"
    fi
  else
    printf "$json" | gh-json message 1>&2
    exit $((http_code - 300))
  fi
}

_git_hub_oauth(){
  # TODO add option `-f` force to regenerate the token
  user=`git config github.user`
  test -z "$user" && echo "failed to fetch github.user" 1>&2 && exit 1
  oauthToken=`git config github.oauthToken`
  if [ -z $oauthToken ] ; then
    echo "Github oAuth token not found. Creating a new one."
    stty_orig=`stty -g`
    stty -echo
    printf "Github password:"
    read passwd
    stty $stty_orig
    response=$(curl -# -u "$user:$passwd" "https://api.github.com/authorizations" \
              -d '{"scopes": ["repo", "user", "gist"]}' --write-out "%{http_code}")

    json=`echo $response | sed 's/...$//'`
    http_code=`echo -e "$response" | tail -1`

    if [ "${http_code:0:1}" == "2" ] ; then
      oauthToken=$(printf "$json" | gh-json token)
      git config --global github.oauthToken $oauthToken
    else
      printf "$json" | gh-json message 1>&2
      exit $((http_code - 300))
    fi
  fi
  echo $oauthToken
}

test $# -eq 0 && echo "GitHub for hackers" && exit

subcommand=$1
shift
case $subcommand in
  api) _git_hub_api "$@" ;;
  oauth) _git_hub_oauth ;;
esac
