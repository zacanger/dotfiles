#!/usr/bin/python2
#
# Get the start time of one or more processes on a Linux system. This is
# necessary because, annoyingly, ps truncates the value to various times.
# The arguments are PIDs. If the first argument is -a, what is printed is
# not the start time but the age (in seconds).
#
# BUG: the name is misleading.

import time, sys, re

# /proc/uptime's first number is the system uptime in seconds (with a
# fractional component).
def getuptime():
	fp = open("/proc/uptime", "r")
	l = fp.readline()
	fp.close()
	l = l.split()
	return float(l[0])

# This is annoyingly complex.
# The start time of a process, in jiffies (1/100ths of a second) is
# field 22 of /proc/<pid>/stat. Unfortunately this has an odd format.
tailre = re.compile("\) ([^)]*$)")
def getprocstart(pid):
	try:
		fp = open("/proc/%s/stat" % pid, "r")
		l = fp.readline()
		fp.close()
	except EnvironmentError:
		return None
	# get everything after the variable-size, variable-formatted field.
	mo = tailre.search(l)
	if not mo:
		return 0
	l = mo.group(1)
	# Now it is field 20. Much better. (Python will call this index 19.)
	n = l.split()
	# return, converted to seconds.
	return float(n[19])/100

def process(args):
	dostart = 1
	if args[0] == "-a":
		dostart = 0
		args = args[1:]
	l = [(pid, getprocstart(pid)) for pid in args]
	l = [x for x in l if not (x[1] is None)]
	uptime = getuptime()
	now = time.time()
	for pid, startsecs in l:
		sage = uptime-startsecs
		swhen = now - sage
		if dostart:
			print "%6s: %s" % (pid, time.asctime(time.localtime(swhen)))
		else:
			print "%6s: %d" % (pid, int(sage))

if __name__ == "__main__":
	process(sys.argv[1:])
