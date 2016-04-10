#!/usr/bin/env bash

dict=dict.org/d:

curl $dict+$1 | less

