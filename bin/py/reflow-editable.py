#!/usr/bin/env python
"""
reflow-editable: Given some HTML, take appropriate piece of text and reflow
them such that each sentence starts on a new line.
Adam Sampson <ats@offog.org>
"""

import sys, re

class Tokeniser:
	types = [ ("space", re.compile(r"\s+", re.S)),
	          ("tag", re.compile(r"<[^>]*>", re.S)),
	          ("word", re.compile(r"[^\s<]+", re.S)) ]

	def __init__(self, f):
		self.data = f.read()
	def read(self):
		if self.data == "":
			return ("eof", "")
		for (name, exp) in self.types:
			m = exp.match(self.data)
			if m is not None:
				self.data = self.data[m.end(0):]
				return (name, m.group(0))

class Unreadable:
	def __init__(self, parent):
		self.v = None
		self.parent = parent
	def read(self):
		if self.v is None:
			return self.parent.read()
		else:
			v = self.v
			self.v = None
			return v
	def unread(self, v):
		if self.v is not None:
			die("multiple unreads")
		self.v = v

def die(*s):
	sys.stderr.write("error: " + " ".join(map(str, s)) + "\n")
	sys.exit(1)

block_els = set(["p", "li", "td", "th", "h1", "h2", "h3"])
pre_els = set(["pre"])
last_chars = set([".", "!", "?"])
tag_re = re.compile(r"<\s*(/?)\s*(\S+)\s*.*(/?)\s*>", re.S)
text_width = 72
def reflow_from(f):
	tok = Unreadable(Tokeniser(f))
	els = []
	prev_space = None
	width = 0

	while 1:
		(t, v) = tok.read()
		if t == "eof":
			break
		(t1, space) = tok.read()
		if t1 != "space":
			tok.unread((t1, space))
			space = ""

		space_before = None
		space_after = None

		if t == "tag":
			m = tag_re.match(v)
			el = m.group(2).lower()
			if m.group(1) == "/":
				if els[-1] != el:
					die("unmatched close tag in", v)
				els = els[:-1]
				if el in block_els:
					space_before = "\n"
					space_after = "\n\n"
			elif m.group(3) == "/":
				# <br /> or similar
				pass
			else:
				els.append(el)
				if el in block_els:
					space_before = "\n\n"
					space_after = "\n"

		if t == "word" and not any([el in pre_els for el in els]):
			# This gets endings wrong on quoted sentences.
			end = v[-1]
			if end == ")":
				end = v[-2]
			if end in last_chars:
				space_after = "\n"
			else:
				space_after = " "
			if (width + len(v)) > text_width:
				space_before = "\n"

		s = ""
		if prev_space is not None:
			if space_before is not None:
				s = space_before
			else:
				s = prev_space
		s += v
		sys.stdout.write(s)
		if space_after is not None:
			prev_space = space_after
		else:
			prev_space = space

		# This miscalculates when space_before is used next time.
		# (Which doesn't matter, because we don't use the calculated
		# value in that case.)
		ss = s + prev_space
		i = ss.rfind("\n")
		if i != -1:
			width = len(ss) - i - 1
		else:
			width += len(s)

	if prev_space is not None:
		sys.stdout.write(prev_space)

if __name__ == "__main__":
	fns = sys.argv[1:]
	if fns == []:
		reflow_from(sys.stdin)
	else:
		for fn in fns:
			f = open(fn)
			reflow_from(f)
			f.close()

