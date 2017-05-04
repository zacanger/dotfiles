#!/bin/sh

until [ `curl -s -o /dev/null -w "%{http_code}" https://seller.jane.com/-/diag` != '200' ]
do
  sleep 60
done

# npm i -g alert-node
alert 'SELLER IS DOWN'
