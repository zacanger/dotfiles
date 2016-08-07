#!/usr/bin/env python
"""
aget: download items from archive.org, given their "details" URLs.
The files downloaded are limited by extension; you can use this, for
example, to easily download complete live shows in FLAC format just
given the URLs that appear in archive.org's RSS feeds.
Adam Sampson <ats@offog.org>
"""

import sys, urllib, re, os, urlparse, HTMLParser, getopt

class LinkFinder(HTMLParser.HTMLParser):
	def __init__(self, base):
		HTMLParser.HTMLParser.__init__(self)
		self.base = base
		self.links = []

	def handle_starttag(self, tag, attrs):
		if tag == "a":
			for (name, value) in attrs:
				if name == "href":
					self.links.append(urlparse.urljoin(self.base, value))

def get_item_url(detailsurl):
	print "Reading details from", detailsurl
	f = urllib.urlopen(detailsurl)
	details = f.read()
	f.close()

	lf = LinkFinder(detailsurl)
	lf.feed(details)

	for url in lf.links:
		if re.search(r'^https?://ia\d+.*/items/', url) is not None:
			item_url = url
			break
		elif re.search(r'^https?://.*archive.org/download/[^/]*$', url) is not None:
			item_url = url
			break
	else:
		print "Item URL not found in page"
		sys.exit(1)

	print "Item is in", item_url
	return item_url

presets = {
	"audio": {
		"accept": "shn,flac,txt,xml,pdf,jpg",
		"makedir": True,
		},
	"pdf": {
		"accept": "pdf",
		"makedir": False,
		},
	"djvu": {
		"accept": "djvu",
		"makedir": False,
		},
	}

def usage(rc = 1):
	print "Usage: aget [OPTION]... [URL]..."
	print "Download items from archive.org, given their \"details\" URLs."
	print
	print "  -A EXTENSION   add EXTENSION to list of extensions to get"
	print "  -c             don't create a new directory to download to"
	print "  -p PRESET      use PRESET as default settings (default: audio)"
	print "  --help         display this help and exit"
	print
	print "Presets:"
	for (name, settings) in sorted(presets.items()):
		args = "-A %s" % settings["accept"]
		if not settings["makedir"]:
			args += " -c"
		print "  %-8s %s" % (name, args)
	print
	print "Report bugs to <ats@offog.org>."
	sys.exit(rc)

if __name__ == "__main__":
	settings = {}
	settings.update(presets["audio"])

	try:
		opts, args = getopt.getopt(sys.argv[1:], "A:cp:", ["help"])
	except getopt.GetoptError:
		usage()

	for o, a in opts:
		if o == "-A":
			settings["accept"] += "," + a
		elif o == "-c":
			settings["makedir"] = False
		elif o == "-p":
			if not a in presets:
				usage()
			settings.update(presets[a])
		elif o == "--help":
			usage(0)

	commands = []
	for url in args:
		item_url = get_item_url(url)
		if item_url[-1] == "/":
			item_url = item_url[:-1]

		if settings["makedir"]:
			dir = item_url[item_url.rfind("/") + 1:]
		else:
			dir = "."

		cmd = [
			"wget",
			"-c",
			"-r",
			"-l1",
			"-nd",
			"-P", dir,
			"-A", settings["accept"],
			item_url
			]
		rc = os.spawnvp(os.P_WAIT, cmd[0], cmd)
		if rc != 0:
			print "Command failed (exit code %d): %s" % (rc, " ".join(cmd))
			sys.exit(1)
	sys.exit(0)

