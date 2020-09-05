#!/usr/bin/env bash

if [ -z "$EMAIL" ]; then
  echo 'EMAIL is required'
  exit 1
fi

if [ -z "$DOMAIN" ]; then
  echo 'DOMAIN is required'
  exit 1
fi

certbot certonly \
  --manual \
  --preferred-challenges dns \
  -d "$DOMAIN" \
  --config-dir . \
  --work-dir . \
  --logs-dir . \
  --email "$EMAIL" \
  --agree-tos
