#!/bin/sh
# List all (public) repos of a GitHub user in Markdown format
# Usage: gh-repos <user> [<api params>]
# Written by Mathias Lafeldt <mathias.lafeldt@gmail.com>

set -e

GH_USER=$1
shift
GH_PARAMS=${2:-"?per_page=100"}

curl -Ls "https://api.github.com/users/$GH_USER/repos$GH_PARAMS" |
ruby -rjson -e "JSON.parse(STDIN.read).each {|r| puts '* [%s](%s) - %s' % [r['name'], r['html_url'], r['description']]}" |
sort
