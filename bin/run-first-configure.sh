#!/bin/bash

# This Script will amend the simpletum scripts with your working directory for api.key and json.sh.
# If you want to run simpletum from /home/john/simpletum/ . This script will prepend /home/john/simpletum/ to api.key and json.sh. e.x (/home/john/simpletum/api.key)

sed "s|api\.key|$PWD/api.key|" -i simplesou.sh ;

sed "s|./json.sh|$PWD/json.sh|" -i simplesou.sh ;

sed "s|api\.key|$PWD/api.key|" -i simpleurl.sh ;

sed "s|./json.sh|$PWD/json.sh|" -i simpleurl.sh ;

sed "s|api\.key|$PWD/api.key|" -i simplevid.sh ;

sed "s|./json.sh|$PWD/json.sh|" -i simplevid.sh ;

sed "s|api\.key|$PWD/api.key|" -i simpletum.sh ;

sed "s|./json.sh|$PWD/json.sh|" -i simpletum.sh ;

sed "s|api\.key|$PWD/api.key|" -i simplepho.sh ;

sed "s|./json.sh|$PWD/json.sh|" -i simplepho.sh ;
