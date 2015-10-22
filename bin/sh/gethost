#!/bin/bash

#
# --------------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# guelfoweb@gmail.com wrote this file. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return Gianni 'guelfoweb' Amato
# --------------------------------------------------------------------------------
#

# DEPENDENCIES
NC=$( which nc )
if [ -z "$NC" ]; then
	echo "Please install nc."
	exit
fi

# DECLARE
MY_LOCAL_IP=`ifconfig | grep -Eo 'inet(:)?( addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
BASE_IP_LAN=`echo "$MY_LOCAL_IP" | cut -d\. -f1,2,3`

# FUNCTIONS
portscan() {
	echo -e "\nScanning common ports for ip: $IP_ADDR"
	TIMED_OUT=`nc -v -w 1 -z -t $IP_ADDR 80 2>&1 | grep "timed out"`
	if [ -z "$TIMED_OUT" ]; then # not found
		PORT_CSV="21,22,23,25,42,43,53,67,79,80,102,110,115,119,123,135,137,143,161,179,379,389,443,445,465,636,993,995,1026,1080,1433,1434,1521,1677,1701,1720,1723,1900,2409,3101,3306,3389,3390,3535,4321,4664,5190,5500,5631,5632,7070,7100,8000,8799,8880,9100,19430,39720"
		IFS=, port_array=($PORT_CSV) # Split
		for i in "${!port_array[@]}"; do
			nc -v -w 1 -z -t $IP_ADDR ${port_array[$i]} 2>&1 | grep -oh " [0-9]* port \[.*\]\| [0-9]* .* open" # 1-65535	
		done
	else
		echo " Filtered ports"
		return
	fi
}

date_time() {
	DATE_TIME=`date`
	echo -e "\n$DATE_TIME\n"
}

ttl_opsys() {
	if [ "$TTL" != "" ]; then
		if [ "$TTL" -le 32 ]; then
			SYS="Windows NT"
		elif [ "$TTL" -gt 32 ] && [ "$TTL" -le 64 ]; then
			SYS="Linux"
		elif [ "$TTL" -gt 64 ] && [ "$TTL" -le 128 ]; then
			SYS="Windows"
		elif [ "$TTL" -gt 128 ] && [ "$TTL" -le 255 ]; then
			SYS="Unix"
		else
			SYS="---"
			TTL="---"
		fi

		if [ "$HOST" == "$MY_LOCAL_IP" ]; then SYS="$SYS [*]"; fi

		HOST_NAME=`echo $HOST_INFO | cut -d " " -f5 | cut -d\. -f1`
		SYS_CHARS=`echo $SYS | wc -m`
		if [ "$SYS_CHARS" -le 8 ]; then
			echo -e "$HOST\t$TTL\t$SYS\t\t$HOST_NAME"
		else
			echo -e "$HOST\t$TTL\t$SYS\t$HOST_NAME"
		fi
		HOST_ALIVE="$HOST_ALIVE,$HOST"
	fi
}

# MAIN
echo -e "IP ADDRESS\tTTL\tOP SYS\t\tHOSTNAME"
echo -e "----------\t---\t------\t\t--------"

for i in {1..254}; do
  HOST="$BASE_IP_LAN.$i"
  HOST_INFO=`host $HOST`

  echo $HOST_INFO | grep "not found" &>/dev/null
  if [ $? -ne 0 ] ; then
	TTL=`ping -c 1 -w 1 $HOST 2>/dev/null | grep -o "ttl=..." | grep -o "[0-9]*"`
	ttl_opsys
  fi
done

HOST_ALIVE_CSV=`echo "$HOST_ALIVE" | sed 's/^,//'`
IFS=, host_array=($HOST_ALIVE_CSV) # Split
NUM_HOST_ALIVE=${#host_array[@]}

echo -e "\nFound [$NUM_HOST_ALIVE] host(s)."
read -n1 -s -p "Do you want to scan host ports? Press [y] to continue... " key
if [[ $key = "y" ]]; then 
	for i in "${!host_array[@]}"; do
		IP_ADDR=`echo ${host_array[$i]}`
		echo
		portscan
	done
	echo -e "\n\nFinished."
else
	echo -e "\n\nBye!"
	exit
fi
