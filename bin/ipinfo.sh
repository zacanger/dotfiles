#!/bin/sh

curl -sf ipinfo.io | jq .
