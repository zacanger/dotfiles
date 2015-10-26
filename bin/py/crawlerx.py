#
# Written by Porn Crawler
#
#

from Queue import Queue
import re
from urllib import urlopen
from urlparse import urljoin, urlparse
import os.path
import time
import sys
from threading import Thread, Semaphore
import traceback
import shutil

import urllib
urllib.URLopener.version = 'Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0; T312461)'
urllib.FancyURLopener.prompt_user_passwd = lambda self, host, realm: (None, None)


status = {}
has_status = status.has_key

MINSIZE = 400000
QUEUED, VISITED, LOADED, FAILED = range(4)

destdir = r'/home/z/Downloads/'


find_links = re.compile(r"""(?:src|href)=('|")([^"'><]*)\1""", re.I).findall

find_anchors = re.compile(r"""<a(.*) href=([^"'> ]*)""", re.I).findall

find_http = re.compile(r"""('|")((?:http|ftp)://[^"'><]*)\1""", re.I).findall

ignorelink = re.compile(r""".*\.(js|css|jpg|jpeg|gif|png)$""", re.I).match

referlink = re.compile(r"""(http|ftp)://(.*?)(http|ftp)://""", re.I).match

match_movie_url = re.compile(r""".*\.(mpg|mpeg|avi)$""", re.I).match

match_movie = re.compile("^(\x00\x00\x01\xba|RIFF....AVI LIST)").match

match_enum_url = re.compile("(.*?)(\d+)(\.\w{3,4})?$").match
	
enum_blacklisted = re.compile("^http://[^\.]*.yimg.com").match

	

# matches html entities
from htmlentitydefs import entitydefs

entities = []
for (e, s) in entitydefs.items():
	if len(s) == 1: entities.append(e)	
	
entity_sub = re.compile("&(%s);" % '|'.join(entities)).sub
get_match_entitydef = lambda match: entitydefs[match.group(1)]

#unescapes html entities
def unentify(s):
    return entity_sub(get_match_entitydef, s)
    
import Queue
	
class MultiQueue(Queue.Queue):

    def _init(self, (maxq, maxsize)):
        self.maxsize = maxsize
        self.size = 0
        self.queue = [[] for i in range(maxq)]

    def _qsize(self):
        return self.size

    def _empty(self):
        return not self.size

    def _full(self):
        return self.maxsize and (self.size == self.maxsize)

    def _put(self, (i,item)):
        self.queue[i].append(item)
        self.size += 1

    def _get(self):
    	for i in range(len(self.queue)):
    		if self.queue[i]:
    			self.size -= 1
        		return (i, self.queue[i].pop(0))
        		
        		
MOVIE, PAGE = range(2)

queue = MultiQueue((2, 0))

class Worker(Thread):
	def run(self):
		while 1:
			kind, url = queue.get()
			if kind == MOVIE:
				self.domovie(url)
			elif kind == PAGE:
				self.dopage(url)
        		
        	
	def _domovie(self, url):
		""" this is deprecated"""
		# some urls are blacklisted from enumeration because of silly buggers
		#print 'movie   ', url
		if self.getmovie(url) and (not enum_blacklisted(url)):
			print 'got first', url
			# we got the movie ok, so now lets check if its numbered
			enum = match_enum_url(url)
			if enum and len(enum.group(2)) < 4:
				print 'enumerating ', url
				# its numbered, so lets grab the components of this url
				prefix = enum.group(1)
				num = enum.group(2)
				suffix = enum.group(3) or ''
				zeros = len(num)
				numfmt = '%%0%dd' % zeros
				# lets grab movies numbered less than our first
				i = int(num)-1
				while i >= 0:
					print 'enumerating-', prefix + numfmt%i + suffix
					if not self.getmovie(prefix + numfmt%i + suffix):
						# failed, lets try a different numbering format
						if len(str(i)) < zeros:
							# after '11', '10', comes '09', but if that doesnt work, try '9'
							zeros -= 1
							numfmt = '%%0%dd' % zeros
							continue
						else:
							break
						#print 'movie', i, '  ', prefix + numfmt%i + suffix
					i -= 1
				# lets grab movies numbered more than our first
				i = int(num)+1
				numfmt = '%%0%dd' % len(num)
				print 'enumerating+', prefix + numfmt%i + suffix
				while self.getmovie(prefix + numfmt%i + suffix):
					print 'enumerating', prefix + numfmt%i + suffix
					#print 'movie', i, '  ', prefix + numfmt%i + suffix
					i += 1

	def domovie(self, url):
		status[url] = VISITED
		if url.startswith('ftp://'): url0 = url[6:]
		elif url.startswith('http://'): url0 = url[7:]
		else: url0 = url
		tmpname = os.path.join(destdir, '!'+urllib.quote(url0,''))
		name = os.path.join(destdir, urllib.quote(url0,''))
		oldname = os.path.join(destdir, 'old', urllib.quote(url0,''))
		if not (os.path.exists(name) or os.path.exists(oldname)):	
			try:
				conn = urlopen(url)
				length = int(conn.info().get('content-length','0'))
				if  length > MINSIZE:
					data = conn.read(1024)
					if data and match_movie(data):
						print 'saving to', name
						file = open(tmpname, 'wb+')
						while data:
							file.write(data)
							data = conn.read(64*1024)
						file.close()
						os.rename(tmpname, name)
						print 'saved ', length, name
						status[url] = LOADED
						return
			except IOError:
				pass
			except:
				traceback.print_exc()
			status[url] = FAILED

			
	def dopage(self, url):
		print 'page   ', url
		try:
			conn = urlopen(url)
			if conn.info().type == 'text/html':
				html = conn.read()
				links = {}
				for _, link in find_links(html)+find_anchors(html): 
					links[urljoin(url, link)] = 1
				for _, link in find_http(html): 
					links[link] = 1
				for link in links.keys():
					link = unentify(link).strip()
					if (not ignorelink(link)) and (not referlink(link)) and (not has_status(link)):
						if match_movie_url(link):
							queue.put((MOVIE, link))
						else:
							queue.put((PAGE, link))		
						status[link] = QUEUED
			else:
				# its not text/html so lets chuck it in the movie queue and see if its a movie
				queue.put((MOVIE, url))
		except IOError:
			pass
		except:
			traceback.print_exc()
			
			
for url in (sys.argv[1:] or ['http://www.movietitan.com/main.html']):
	if not (url.startswith('http://') or url.startswith('ftp://')):
		queue.put((PAGE, 'http://' + url))
	else:
		queue.put((PAGE, url))
			
for i in range(50):
	w = Worker()
	w.start()
	time.sleep(0.1)

while 1:
	time.sleep(1)

