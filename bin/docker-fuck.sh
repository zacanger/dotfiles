#!/bin/sh

docker kill `docker ps -q`
docker rm -f `docker ps -aq`
