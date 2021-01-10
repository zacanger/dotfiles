#!/usr/bin/env python3
import sys
import yaml  # pip install PyYAML
from nested_lookup import nested_lookup  # pip install nested-lookup

# Example:
# helm template jenkins/jenkins | ./this-script.py
# cat foo.yml | ./this-script.py

template = ""

for line in sys.stdin:
    template += line

parts = template.split('---')
for p in parts:
    y = yaml.safe_load(p)
    matches = nested_lookup("image", y)
    if (len(matches)):
        print("\n".join(matches))
