#!/usr/bin/env bash

echo "Ready?"
sleep 2

apt update
apt full-upgrade -y --allow-unauthenticated --fix-missing

npm i -g n
n latest
npm i -g npm
npm update -g

clear
echo "Done!"

