#!/bin/sh

# fix commits made while git config user.name
# and user.email weren't set.

# run this at repo root like so:
# ./this-script-name.sh old-email good=user-name

rep=$4
git clone --bare $rep
name=${rep##*/}
cd $name

command="
OLD_EMAIL=$1
CORRECT_NAME=$2
CORRECT_EMAIL=$3
if [ \"\$GIT_COMMITTER_EMAIL\" = \"\$OLD_EMAIL\" ]
then
    export GIT_COMMITTER_NAME=\"\$CORRECT_NAME\"
    export GIT_COMMITTER_EMAIL=\"\$CORRECT_EMAIL\"
fi
if [ \"\$GIT_AUTHOR_EMAIL\" = \"\$OLD_EMAIL\" ]
then
    export GIT_AUTHOR_NAME=\"\$CORRECT_NAME\"
    export GIT_AUTHOR_EMAIL=\"\$CORRECT_EMAIL\"
fi
"
echo $command
git filter-branch --env-filter "$command" --tag-name-filter cat -- --branches --tags

git config user.name $2
git config user.email $3
git push --force --tags origin "refs/heads/*"

cd ..
rm -rf $name

