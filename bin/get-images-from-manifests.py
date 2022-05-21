#!/usr/bin/env python3
import sys
import yaml  # pip install PyYAML
from nested_lookup import nested_lookup  # pip install nested-lookup

# Example:
# helm template jenkins/jenkins | ./this-script.py
# cat foo.yml | ./this-script.py

TEMPLATE = ""

for line in sys.stdin:
    TEMPLATE += line

parts = TEMPLATE.split('---')
for p in parts:
    y = yaml.safe_load(p)
    matches = nested_lookup("image", y)
    if len(matches):
        print("\n".join(matches))
