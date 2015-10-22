#!/usr/bin/python

#PLDownloader by slacknux

import urllib
import urllib2
import cookielib
import re
import sys
import time

def urlFinder(lnk):
	print "[*]Extracting URL\n"
	req = urllib2.urlopen(lnk)
	hash_value = re.search('<input type="hidden" value="(.*?)" name="hash"', req.read())
	params = urllib.urlencode({'hash':hash_value.group(1), 'confirm':'Continue+as+Free+User'})
	cj = cookielib.CookieJar()
	opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
	req = opener.open(lnk, params)
	lnk2 = re.search('playlist: \'(.*?)\'', req.read())
	req = opener.open("http://www.putlocker.com"+lnk2.group(1))
	videoURL = re.search('url="(.*?)"', req.read())
	cj.clear()
	return videoURL.group(1)


def nameFinder(lnk):
	print "[*]Extracting name\n"
	part = lnk.split("/")
	videoName = re.search('(.*?\.flv)', part[len(part)-1])
	return videoName.group(1)


def downloadProgress(fileSize):
	downloadSize = 0
	timeSpent = 0
	speed = 0
	step = time.time()

	while True:
		start = time.time()
		chunk = u.read(8192)

		if not chunk:
			time.sleep(1)
			print "\033[0K\t\tDownload completed\n"
			break

		end = time.time()

		if end - step >= 2:
			timeSpent = end - start
			speed = (len(chunk) / 1024) / timeSpent
			step = end

		downloadSize += len(chunk)
		f.write(chunk)
		remaining = ((fileSize - downloadSize) / len(chunk)) * timeSpent
      
		if remaining >= 60 and remaining < 3600:
			remaining = "%d min" % (remaining / 60)
		elif remaining < 60:
			remaining = "%d s" % remaining
		else:
			remaining = "%d h" % (remaining / 3600)

		percent = int(downloadSize * 100 / fileSize)
		status = "\033[0J " + "\t\t%.2f MB of %.2f MB\t%d%%\t%d kB/s   %s" % (downloadSize / 1048576.0, fileSize / 1048576.0, percent, speed, remaining)
		status += "\033[1A"
		print status


def usage():
	print "USAGE: PLDownloader [URL]\n"
	sys.exit(1)



print " ___, __    ____, ____, __    _, ____,   __    ____, ___,   ____, ____, ___,"  
print "(-|_)(-|   (-|  \(-/  \(-| | |  (-|  |  (-|   (-/  \(-|_\_,(-|  \(-|_, (-|_)"  
print " _|   _|__, _|__/  \__/ _|_|_|   _|  |_, _|__,  \__/ _|  )  _|__/ _|__, _| \_,"
print "(    (     (           (        (       (           (      (     (     (" 
print"\t\t\t\t by slacknux\n"

if len(sys.argv) != 2:
	usage()

url = urlFinder(sys.argv[1])

if "&amp;" in url:
	url = url.replace("&amp;", "&")

fileName = nameFinder(url)
print "[*]Name: %s\n" % fileName
print "[*]URL: %s\n" % url
u = urllib2.urlopen(url)
f = open(fileName, 'wb')
meta = u.info()
fileSize = int(meta.getheaders("Content-Length")[0])
print "[*]Downloading: %s" % fileName

downloadProgress(fileSize)

f.close()
