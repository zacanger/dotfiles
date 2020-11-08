#!/usr/bin/env bash
set -e

# add newlines to files with noeol
find . \
  -type f \
  -exec \
  sh -c "tail -1 {} | xxd -p | tail -1 | grep -v 0a$" ';' \
  -exec \
  sh -c "echo >> {}" ';'
