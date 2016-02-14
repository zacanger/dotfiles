#!/usr/bin/env bash

#######################################################
# kxt is a switchable script for useful bash commands #
# it takes each particular tool as an argument        #

###########################################################################
#Copyright (C) 2013 Joe Brock <DebianJoe@linuxbbq.org>                    #
#                                                                         #
#    This program is free software: you can redistribute it and/or modify #
#    it under the terms of the GNU General Public License as published by #
#    the Free Software Foundation, either version 3 of the License, or    #
#    (at your option) any later version.                                  #
#                                                                         #
#    This program is distributed in the hope that it will be useful,      #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of       #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
#    GNU General Public License for more details.                         #
#                                                                         #
#    You should have received a copy of the GNU General Public License    #
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.#
###########################################################################
#    wget https://raw.github.com/DebianJoe/killxdots/master/kxt           #
#    curl https://raw.github.com/DebianJoe/killxdots/master/kxt > kxt     #


if [ $# -lt 1 ]; then
    # no tool specified, list tools for user #
    printf "\033[31;4m......-Tools-......\033[1;m\n"
    printf "\033[1;34msyntax = 'kxt <name_of_tool>"
    printf "\033[1;m\n"
    printf "\033[1;32m%13s\033[1;m..%s\n" "dirtree" \
	"display dir and subdirs as a tree"
    printf "\033[1;32m%13s\033[1;m..%s\n" "dirclean" \
	"removes empty directories"
   printf "\033[1;32m%13s\033[1;m..%s\n" "homeclean" \
	"removes backup~ files"
    printf "\033[1;32m%13s\033[1;m..%s\n" "sort" \
	"sorts files and subdirectories by size"
    printf "\033[1;32m%13s\033[1;m..%s\n" "dist-upgrade" \
	"cycles through and updates ALL git repos"
    printf "\033[1;32m%13s\033[1;m..%s\n" "snail" \
	"converts filename spaces to underscores.(current dir)"
    printf "\033[1;32m%13s\033[1;m..%s\n" "gitfind" \
	"lists all files tied to git repos"
    printf "\033[1;32m%13s\033[1;m..%s\n" "gitorigin" \
	"prints full url for the repo's origin...(current dir)"
    printf "\033[1;32m%13s\033[1;m..%s\n" "gitdiff" \
	"Diffs ONLY the most recent change.......(current dir)"
else

case "$1" in
    "dirtree")
	    # display directory tree #
	    ls -R | grep ":$" \
		| sed -e 's/:$//' \
		-e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
	    ;;
    "gitfind")
	    # print listing of all directories #
	    # that contain a .git dir #
	    find ~/ -name ".git" | sed -e 's/\.git//'
	    ;;
    "dirclean")
	    # removes directories with no content #
	    find . -depth  -type d  -empty -exec rmdir {} \;
	    ;;
    "homeclean")
	    # removes files ending with "~" #
	    # prompts user before deletion, for #
	    # added safety #
	    backs=$(find ~/ -name "*~" -print0 | xargs -0)
	    dotbacks=$(find ~/ -name "*~" -print0 | xargs -0)
	    if [ -n "$backs" ]; then
		rm -i $(find ~/ -name "*~" -print0 | xargs -0)
	    elif [ -n "$dotbacks" ]; then
		rm -i $(find ~/ -name ".*~" -print0 | xargs -0)
	    else
		echo "No Backups Found"
	    fi
	    ;;
    "sort")
	    # prints out files and subdirectoreis by size #
	    du -sk ./* | sort -n | awk \
	    'BEGIN{ pref[1]="K"; pref[2]="M"; pref[3]="G";} \
            { total = total + $1; x = $1; y = 1; while( x > 1024 ) \
            { x = (x + 1023)/1024; y++; } \
            printf("%g%s\t%s\n",int(x*10)/ \
            10,pref[y],$2); } END \
            { y = 1; while( total > 1024 ) \
            { total = (total + 1023)/1024; y++; } \
            printf("Total: %g%s\n",int(total*10)/10,pref[y]); }'
	    ;;
    "gitorigin")
	    # prints url for the current git repo's origin #
	    [ -d "$PWD/.git" ] && \
	    grep url $PWD/.git/config | sed -r 's/^([^ ]+ ){2}//' \
	    || echo "Current directory is NOT a git repo"
	    ;;
    "gitdiff")
	    # shows diff file for last change #
	    [ -d "$PWD/.git" ] && git diff HEAD^ HEAD \
            || echo "Current directory is NOT a git repo"
	    ;;
    "dist-upgrade")
	    # updates ALL git repos, possible breakage #
	    for d in `find ~/. -name .git -type d`; do
		cd $d/.. > /dev/null
		printf "\033[1;33m%s %s\033[1;m\n" "Updating" "$PWD"
		git pull
		cd - > /dev/null
	    done
	    ;;
    "snail")
	    # converts all spaces in PWD to underscores #
	    for f in *\ *; do mv -- "$f" "${f// /_}"; done
	    ;;
    # if no matches found #
    *)	    printf "\033[31;4mNo Matching Tools found\033[1;m\n"
esac
fi

