#!/bin/bash


if [[ $EUID -ne 0 ]] ; then
	echo "Are you root?" 2>&1
	echo
	echo "Solution: run 'sudo system2iso_distro-defaults'"
	exit 1
fi


WORK=/sys2iso/work

if [ -d ${WORK} ]; then
	sudo nano ${WORK}/rootfs/etc/issue
	sudo nano ${WORK}/rootfs/etc/lsb-release 
	sudo nano ${WORK}/rootfs/etc/os-release
	sudo nano ${WORK}/rootfs/etc/network/interfaces
	sudo ncdu ${WORK}
else
	echo "No ${WORK} directory found, exiting."
	echo "Solution: run 'sudo system2iso' first."
	echo
	exit 1
fi

