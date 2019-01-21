#!/usr/bin/env python3
import csv, json, sys
for row in csv.DictReader(sys.stdin):
    json.dump(row, sys.stdout)
    sys.stdout.write('\n')