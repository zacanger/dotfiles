#!/bin/sh

curl -s https://some.audio/diag | jq .count
