#!/usr/bin/env bash

git --no-pager log \
  --date=iso \
  --since="2 months" \
  --date-order \
  --full-history \
  --all \
  --pretty=tformat:"%C(cyan)%ad%x08%x08%x08%x08%x08%x08%x08%x08%x08 %C(bold red)%h %C(bold blue)%<(22)%ae %C(reset)%s"

