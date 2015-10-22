#!/bin/bash
#Bulk Downloads a users pastbin files
if [ $# -lt 1 ]
then
    echo "Useage: $0 <user> <number of Pages>"
    echo "Example: $0 metalx1000 2"
else

user="$1"
if [ $# -lt 2 ]
then
    let pages=1
    echo "Downloading $pages of ${user}'s pastes."
else
    let pages=$2
    echo "Downloading $pages of ${user}'s pastes."
fi

tmp="pastbin"
mkdir "$tmp"
cd "$tmp"

for x in $(seq 1 $pages)
do
    echo "Downloading Page $x"
    wget -q "http://pastebin.com/u/$user/$x" -O-|grep "t.gif"|grep "Public paste"|while read line
    do
        id="$(echo $line|cut -d\" -f12|cut -d\/ -f2)"
        title="$(echo $line|cut -d\" -f13|cut -d\> -f2|cut -d\< -f1|cut -d\. -f1)"
        url="http://pastebin.com/raw.php?i=${id}"
        echo "Downloading $title..."

        wget -q -c "$url" -O "$title"

        type="$(head -n1 "$title")"

        if [[ $type == *bash* ]]
        then
            mv "$title" "${title}.sh"
        elif [[ $type == *python* ]]
        then
            mv "$title" "${title}.py"
        fi

    done
done

dos2unix *

zip -r ../pastebin_backup_$(date +%s).zip *
cd ../
rm -fr "$tmp"

fi
