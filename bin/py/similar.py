#!/usr/bin/python
# Given a list of files on stdin, one per line, identify those that are
# *nearly* duplicates.
# Adam Sampson <ats@offog.org>

import sys, argparse

args = None

def count_diffs(a, b):
	la, lb = len(a), len(b)
	diffs = 0
	for i in range(min(la, lb)):
		if a[i] != b[i]:
			diffs += 1
	# If the lengths differ, count the non-matching section as all
	# different.
	# FIXME: option to treat missing bits as a byte value instead
	if la != lb:
		diffs += abs(la - lb)
	return diffs

class File:
	def __init__(self, fn):
		self.fn = fn

		# Read some bytes from the start of the file.
		# FIXME: how many?
		size = args.diff_bytes * 2
		f = open(fn, "rb")
		self.start = f.read(size)
		f.close()

		self.similar = []

	def compare(self, other):
		"""Return the number of differences between two Files.
		If the files are too different to group, return None."""

		# Compare the cached starts.
		max_diffs = args.diff_bytes
		if count_diffs(self.start, other.start) > max_diffs:
			return None

		# Not enough difference in the starts to rule this
		# pair out. Compare the complete files.
		diffs = 0
		chunk = 65536
		# FIXME: cache open filehandle
		af = open(self.fn, "rb")
		bf = open(other.fn, "rb")
		while True:
			a = af.read(chunk)
			b = bf.read(chunk)
			if a == "" and b == "":
				break
			diffs += count_diffs(a, b)
			if diffs > max_diffs:
				return None
		af.close()
		bf.close()

		return diffs

	def add_similar(self, other, diffs):
		self.similar.append((diffs, other.fn, other))

def main(argv):
	global args
	parser = argparse.ArgumentParser(description="Identify similar files.")
	parser.add_argument("--diff-bytes", "-b", metavar="N",
	                    default=0, type=int,
	                    help="group files with N or fewer differences (default: 0)")
	args = parser.parse_args(argv)

	files = {}
	for line in sys.stdin.readlines():
		fn = line[:-1]
		file = File(fn)

		for ofn, other in files.items():
			diffs = file.compare(other)
			if diffs is not None:
				file.add_similar(other, diffs)
				other.add_similar(file, diffs)

		files[fn] = file

	for fn, file in sorted(files.items()):
		print fn
		for diffs, ofn, other in sorted(file.similar):
			print "  %6d %s" % (diffs, ofn)
		print

if __name__ == "__main__":
	main(sys.argv[1:])
