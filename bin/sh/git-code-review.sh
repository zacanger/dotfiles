#!/usr/bin/env bash

# Helper script for anyone that has to review Ken's massive pull requests
#
# Usage:
#  0. Save this file as ~/bin/code-review, make it executable and put it in your $PATH
#  1. Use https://gist.github.com/3342247 to get a local copy of the PR
#  2. Save this as ~/bin/code-review
#  3. $ git checkout pr/foo
#  4. $ git diff develop.. --oneline |code-review
#

tac () {
    awk '1 { last = NR; line[last] = $0; } END { for (i = last; i > 0; i--) { print line[i]; } }'
}

tac |while read sha msg; do
  echo "Reviewing $sha: $msg"
  git show $sha
done
