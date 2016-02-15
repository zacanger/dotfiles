#!/bin/sh

_git_ssh_key_usage(){
  echo "git ssh-key
git ssh-key add <title> <key_file>
git ssh-key rm <key_id>"
}

_git_ssh_key_list(){
  git hub api GET /user/keys "" "id title"
}

_git_ssh_key_add(){
  title="$1"
  pubkey_file="$2"

  test -z "$title" && echo "title required" 1>&2 && exit 1
  test -z "$pubkey_file" && echo "key file required" 1>&2 && exit 2
  test ! -e "$pubkey_file" && echo "No such key file '$pubkey_file'" 1>&2 && exit 3
  test -d "$pubkey_file" && echo "'$pubkey_file' is a directory" 1>&2 && exit 4

  body="{\"title\": \"$title\", \"key\": \"$(cat $pubkey_file)\"}"
  git hub api POST /user/keys "$body" > /dev/null && echo "ssh-key was created"
}

_git_ssh_key_rm(){
  id=$1
  test -z $id && echo "id required." 1>&2 && exit 1
  git hub api DELETE /user/keys/$id && echo "ssh-key was deleted"
}

test $# -eq 0 && _git_ssh_key_list && exit

subcommand=$1
shift
case $subcommand in
  add) _git_ssh_key_add $* ;;
  rm) _git_ssh_key_rm $* ;;
  *) _git_ssh_key_usage ;;
esac
