#!/bin/bash

# Log commits which are reachable from the branch specified as the first
# argument to this script, and not reachable from any other branches in the
# repository. Additional arguments provided beyond the first are passed to the
# underlying `git log` command

if [[ -n $1 ]]; then
    ref=$1
    shift
else
    ref=HEAD
fi
git log "$@" $(
    git rev-list $ref |
    while read commit; do
        if
            [[ `
                git branch --contains $commit |
                wc -l
            ` -gt 1 ]] ||
                [[ `
                    git cat-file -p $commit |
                    sed /^$/q |
                    grep -c ^parent
                ` -gt 1 ]]
        then
            echo $commit
            break
        fi
    done
)..$ref
