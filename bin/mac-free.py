#!/usr/bin/env python3

# there's no free on macs

import subprocess
import re

# Get process info
ps = (
    subprocess.Popen(["ps", "-caxm", "-orss,comm"], stdout=subprocess.PIPE)
    .communicate()[0]
    .decode()
)
vm = (
    subprocess.Popen(["vm_stat"], stdout=subprocess.PIPE)
    .communicate()[0]
    .decode()
)

# Iterate processes
process_lines = ps.split("\n")
sep = re.compile("[\s]+")
rss_total = 0  # kB
for row in range(1, len(process_lines)):
    rowText = process_lines[row].strip()
    row_elements = sep.split(rowText)
    try:
        rss = float(row_elements[0]) * 1024
    except:
        rss = 0  # ignore...
    rss_total += rss

# Process vm_stat
vmLines = vm.split("\n")
sep = re.compile(":[\s]+")
vm_stats = {}
for row in range(1, len(vmLines) - 2):
    rowText = vmLines[row].strip()
    row_elements = sep.split(rowText)
    vm_stats[(row_elements[0])] = int(row_elements[1].strip("\.")) * 4096

print("Wired Memory:\t\t%d MB" % (vm_stats["Pages wired down"] / 1024 / 1024))
print("Active Memory:\t\t%d MB" % (vm_stats["Pages active"] / 1024 / 1024))
print("Inactive Memory:\t%d MB" % (vm_stats["Pages inactive"] / 1024 / 1024))
print("Free Memory:\t\t%d MB" % (vm_stats["Pages free"] / 1024 / 1024))
print("Real Mem Total (ps):\t%.3f MB" % (rss_total / 1024 / 1024))
