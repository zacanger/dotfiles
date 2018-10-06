#!/bin/sh
for containerid in `docker ps --format "{{.Names}}"`; do
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock red5d/docker-autocompose $containerid >> autocompose.txt
done
