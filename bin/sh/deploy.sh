#!/usr/bin/env bash

# gh:zacanger 2016

# simple shell script to put stuff on your server
# edit the variables to suit

# `APP_NAME` - name of your site/app
# `SSH_HOST` - user and hostname of server
# `APP_DIR` - where your files go on server
# `BUNDLE_CMD` - command to create bundle.tgz containing all files to upload.
# (uses git by default)

# then just type `./deploy.sh` and you're done

# need dependencies? add `npm i` or `bundle install` or whatever
# (after the bundle.tgz extraction).
# need other stuff? just add another line! done.

APP_NAME="my_app"
SSH_HOST="me@my.site"
APP_DIR="/srv/something/$APP_NAME"

BUNDLE_CMD="git archive -o bundle.tgz HEAD"

echo Deploying...
$BUNDLE_CMD > /dev/null 2>&1 &&
scp bundle.tgz $SSH_HOST:/tmp/ > /dev/null 2>&1 &&
rm bundle.tgz > /dev/null 2>&1 &&
ssh $SSH_HOST 'bash -s' > /dev/null 2>&1 <<ENDSSH
if [ ! -d "$APP_DIR" ]; then
  mkdir -p $APP_DIR
else
  rm -rf $APP_DIR/*
fi
pushd $APP_DIR
  tar xfz /tmp/bundle.tgz -C $APP_DIR
  rm /tmp/bundle.tgz
popd
ENDSSH
echo Done.

