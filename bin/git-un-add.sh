#!/usr/bin/env bash
set -e

git reset "$1" && git checkout "$1"
