#!/bin/bash

[ "$1" = "" ] && printf "${yell}Usage : $0 /path/to/dir \n ${reset}" && exit
printf ${green}
du -hs --apparent-size $1
printf ${reset}

exit 0

