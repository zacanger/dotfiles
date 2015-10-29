#!/bin/bash

selfdir=$(cat ~/.laenza/selfdir)
source "$selfdir/conf/media.conf"

"$selfdir/plugins/media/${media}.sh"
