#!/bin/sh

find . | perl -ne 'print if /[^[:ascii:]]/'
