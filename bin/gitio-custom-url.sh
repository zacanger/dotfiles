#!/usr/bin/env bash
set -e

read -rp 'url? ' url
read -rp 'path? ' path
curl https://git.io/ -i -F "url=$url" -F "code=$path"
