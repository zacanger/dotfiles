#!/usr/bin/env bash

docker ps -a | grep "Exit" | awk '{print $1}' | while read -r id ; do
  docker rm $id
done

