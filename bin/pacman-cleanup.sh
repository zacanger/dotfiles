#!/bin/sh
set -e

pacman-mirrors -g
pacman-db-upgrade
sync
