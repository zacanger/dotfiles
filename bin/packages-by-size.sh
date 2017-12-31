#!/usr/bin/env bash

dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -rn
