#!/usr/bin/env bash

# specialized wrapper for `gem`, to install cli tools in isolated location
# independent of rvm/rbenv version
# put `global` in PATH. add `~/.gem/global/bin` to PATH, AFTER rbenv/RVM
# config lines.
# usage: `global provide` (gem name)
# `global install` (gem name) (-v (version))
# `global uninstall` ''           ''

set -e

export GEM_HOME="$HOME/.gem/global"
export RBENV_VERSION=2.2.3p173 # configure your Ruby version of choice here
export -n RUBY_GC_MALLOC_LIMIT
export -n RUBY_FREE_MIN

cmd="$1"
[[ -z $cmd ]] && die=1 || die=0

if [[ $die -gt 0 || $1 = "-h" || $1 = "--help" ]]; then
  sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' < "$0" >&$((die+1))
  exit $die
fi

shift 1

generate_binstubs() {
  for file in "$GEM_HOME/gems/$1"-*/bin/*; do
    generate_binstub "$1" "${file##*/}"
  done
}

generate_binstub() {
  gemname="${1?}"
  stubname="${2?}"
  binstub="$GEM_HOME/bin/$stubname"

  mkdir -p "${binstub%/*}"
  cat > "$binstub" <<SH
#!$(rbenv which ruby)
ENV['GEM_HOME'] = ENV['GEM_PATH'] = '$GEM_HOME'
\$0 = File.basename(\$0)
require 'rubygems'
gem '$gemname'
load Gem.bin_path('$gemname', '$stubname')
SH
  chmod +x "$binstub"
}

flags=
if [[ "install" = ${cmd}* || "update" = ${cmd}* ]]; then
  # don't install binstubs; later we'll manually setup just the ones we need:
  flags="--no-rdoc --no-ri --bindir ${TMPDIR:-/tmp}/trashbin"
  if [[ "update" = ${cmd}* ]]; then
    gemname="$1"
    if [ -z "$gemname" ]; then
      echo "you must provide a gem name for \`update'" >&2
      exit 1
    fi
    # match the exact gem name instead of acting as a pattern
    flags="$flags ^$gemname$"
    shift 1
  fi
elif [[ "uninstall" = ${cmd}* ]]; then
  flags="--all --executables"
elif [[ "binstubs" = ${cmd}* ]]; then
  generate_binstubs "$1"
  exit
elif [[ "provide" = ${cmd}* ]]; then
  $0 install "$1"
  $0 binstubs "$1"
  exit
fi

GEM_PATH="$GEM_HOME" exec gem "$cmd" $flags "$@"

