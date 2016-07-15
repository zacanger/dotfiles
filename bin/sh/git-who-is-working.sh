#!/bin/sh
# See how many commits each person have done

pgm=${0##*/}

while [ $# -gt 0 ]; do
  case "$1" in
    -p|--pull) q_pull=1;;
    *) printf "Usage: '%s [--pull]'\n" "$pgm"; exit 2;;
  esac
  shift
done

repo_root="$HOME/work/Sitemule-repos"
cd "$repo_root" || exit 5
for dir in *; do
  if [ ! -d "$dir" ] || ! cd "$dir"; then
    continue
  fi
  [ -n "$q_pull" ] && git pull >&2
  git shortlog --summary
  cd "$repo_root" || exit 5
done | awk '{n = $1; $1=""; c[$0] += n}END{for (k in c) {print k " " c[k]}}'
