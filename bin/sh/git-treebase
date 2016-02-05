#!/bin/bash

# Rebase a "tree" (connected DAG) of Git branches onto a common new base
# 
# Usage:
#     
#     git treebase <New base> <Main branch>
#

branches=$(
    git branch --contains `
        git rev-list $1..$2 |
        tail -n 1
    ` |
    sed 's/^..//'
)    

echo $branches
echo -n 'Rebase these branches? Warning: merges will not be preserved! (y/n)>'
read
[[ $REPLY != y ]] &&
    exit

for b in $branches; do
    git rebase --committer-date-is-author-date $1 $b
done
