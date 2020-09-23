#!/usr/bin/env bash
set -e

find . | perl -ne 'print if /[^[:ascii:]]/'
