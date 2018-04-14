#!/bin/sh

# set fastest mirror
pacman-mirrors -g

# upgrade and optimize db
pacman-db-upgrade && pacman-optimize && sync
