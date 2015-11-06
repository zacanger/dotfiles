#! /bin/bash
#check for necessary programs:
command -v scrot >/dev/null 2>&1 || { echo "I require foo but it's not installed. Aborting." >&2; exit 1; }
command -v rsync >/dev/null 2>&1 || { echo "I require foo but it's not installed. Aborting." >&2; exit 1; }

date=`date +%Y-%m-%d-%I%M%S`
local_save_dir="/home/"
pic=$date".png"

server="yourserver.com"
server_save_dir="/dir/where/your/web/server/can/serve/"

should_delete_local=true # will delete the local copy when done

scrot -s 'pic.png'
mv pic.png $local_save_dir$pic

rsync --progress $local_save_dir$pic $server:$server_save_dir$pic

echo "http://"$server/$pic | xclip -selection c

if $should_delete_local ;
	then
		rm $local_save_dir$pic
fi

exit
