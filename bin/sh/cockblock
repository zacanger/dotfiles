#!/bin/sh
##
## THIS SCRIPT WAS WRITTEN BY CRANKLIN
## http://www.cranklin.com
##
if [ $# -eq 0 ]
then
        /sbin/iptables -L -n
        exit 0
else
        if [ $1 = unblock ]
        then
                if [ `echo $2 | egrep -c '^([0-9]+(\.[0-9]+){3})$'` -eq 1 ]
                then
                        ip=$2
                        /sbin/iptables -D INPUT -s $ip -j DROP
                        echo "/sbin/iptables -D INPUT -s $ip -j DROP" >> ~/cockblocklist
                        echo "$ip has been unBLOCKED!"
                else
                        echo "$2 is not a valid IP!"
                fi
        else
                if [ $1 = forceadd ]
                then
                        if [ `echo $2 | egrep -c '^([0-9]+(\.[0-9]+){3})$'` -eq 1 ]
                        then
                                ip=$2
                                if [ `cat ~/cockblocklist | grep -c $ip` -lt 1 ]
                                then
                                        echo "/sbin/iptables -A INPUT -s $ip -j DROP" >> ~/cockblocklist
                                        echo "$ip has been added to the list!"
                                else
                                        echo "$ip is already on the list!"
                                fi
                        else
                                echo "$2 is not a valid IP!"
                        fi
                else
                        if [ `echo $1 | egrep -c '^([0-9]+(\.[0-9]+){3})$'` -eq 1 ]
                        then
                                ip=$1
                                if [ `/sbin/iptables -L -n | grep -c $ip` -lt 1 ]
                                then
                                        /sbin/iptables -A INPUT -s $ip -j DROP
                                        echo "/sbin/iptables -A INPUT -s $ip -j DROP" >> ~/cockblocklist
                                        echo "$ip has been cockBLOCKED!"
                                else
                                        echo "$ip is already BLOCKED!"
                                fi
                        else
                                echo "$1 is not a valid IP!"
                        fi
                fi
        fi
fi

