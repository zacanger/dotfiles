#!/bin/sh
until [ `curl -s seller.jane.com/-/diag | jq .status` != '"OK"' ]
do
  sleep 60
done
zenity --error --text "SELLER IS DOWN"
