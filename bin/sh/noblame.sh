#!/bin/bash

# soft mode, appends extra fake commit.
# hard mode, with -f, actually rewrites things
# noblame -f -a badguy 1-$ file
# takes a while. be careful.
#
# parse options
usage (){
    echo 'usage:' `basename $0` '[ -a <author> ] [ -e <email> ] range file'
    exit
}

if [[ ! -d .git ]]; then
    echo "error: Not a git repository."
    exit
fi

while getopts "hfa:e:" flag; do
  case $flag in
    a) author=$OPTARG;;
    e) email=$OPTARG;;
    f) force=1;;
    h) usage;;
    \?) usage;;
  esac
done

shift $(($OPTIND - 1))

range=$1
file=$2

if [[ -z $file ]]; then
    echo "error: No file is specified."
    exit
fi

# parse range pattern
range_arr=$(echo $range|tr ",-" "\n,")

# get real user and email
real_user=`git config user.name`
real_addr=`git config user.email`

# set fake user as current user
fake_user=${author:-$real_user}
fake_addr=${email:-$real_addr}

# hard_mode use git filter-branch to rewrite history
hard_mode (){
    tmp_file="${TMPDIR%/}/blamehe-$$.$RANDOM"
    for r in $range_arr; do
        git blame --abbrev=40 $file|sed -n "$r p"|cut -d " " -f 1|sed 's/^\^//' >> $tmp_file
    done

    git filter-branch -f --env-filter "
        if grep \$GIT_COMMIT $tmp_file >/dev/null 2>&1; then
            GIT_AUTHOR_NAME=$fake_user
            GIT_AUTHOR_EMAIL=$fake_addr
        fi
    " -- HEAD

    rm $tmp_file
}

# soft_mode appends an extra commit with fake user's name and email address
soft_mode (){
    # append *one* space to target lines
    for r in $range_arr; do
        sed -i '' -e "$r s/$/ /" $file
    done

    # do commit as fake_user
    git add $file
    git commit -m 'make some minor changes :P' --author="$fake_user <$fake_addr>"
}

if [[ $force ]]; then
    hard_mode
else
    soft_mode
fi

echo "Done yean!"
