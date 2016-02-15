#!/bin/bash

# List Installed Packages ordered by size
# (c) 2013 Lukasz Grzegorz Maciak

dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -rn 
