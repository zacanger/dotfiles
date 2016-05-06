#!/usr/bin/env bash

sudo rm /var/lib/mongodb/mongod.lock
sudo -u mongodb mongod -f /etc/mongodb.conf --repair
sudo start mongodb
sudo status mongodb

