#!/bin/sh
if [ $1 ]; then 
	if [ $1 = 'search' ]; then 
		apt-cache search --names-only $2
	fi 
	if [ $1 = 'show' ]; then
		apt-cache $*
	fi
	if [ $1 = 'update' ] || [ $1 = 'install' ]; then
		apt-get -y $*
	fi
	if [ $1 = 'list' ]; then
		dpkg --$*
	fi
	if [ $1 = 'clean' ]; then
		apt-get autoremove && apt-get clean && apt-get autoclean
	fi
	if [ $1 = 'upgrade' ]; then
		apt-get update && apt-get dist-upgrade
	fi
else
	echo -n "Usage:\n"
	echo -n "kkm clean\t\t#clean and remove unused packages\n"
	echo -n "kkm search  packagename\t\t#search packages\n"
	echo -n "kkm show  packagename\t\t#display information of  packages\n"
	echo -n "kkm update\t\t#update package database\n"
	echo -n "kkm upgrade\t\t#upgrade all installed package\n"
	echo -n "kkm install packagename\t\t#install packages\n"
	echo -n "kkm list\t\t#list installed packages\n"
fi
