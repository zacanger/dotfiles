#!/bin/sh

echo u > /proc/sysrq-trigger ; sleep 2 ; echo s > /proc/sysrq-trigger ; \
sleep 2 ; echo b > /proc/sysrq-trigger

