#!/bin/sh
addr `sdig ns $1` | sort -u
