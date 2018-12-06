#!/usr/bin/env bash

mplayer -playlist <(find "$PWD" -type f | sort)
