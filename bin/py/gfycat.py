#!/usr/bin/python
from urllib import urlretrieve
import requests
from random import randint
from time import sleep
from os import walk
import signal
import sys


def l(mess):
        sys.stdout.write(mess)
        sys.stdout.flush()

def create_request(filename, key):
	with open(filename,'rb') as fp:
                payload = [('acl','private'),
                           ('AWSAccessKeyId','AKIAIT4VU4B7G2LQYKZQ'),
                           ('success_action_status', '200'),
                           ('signature','mk9t/U/wRN4/uU01mXfeTe2Kcoc='),
                           ('Content-Type','image/gif'),
                           ('policy','eyAiZXhwaXJhdGlvbiI6ICIyMDIwLTEyLTAxVDEyOjAwOjAwLjAwMFoiLAogICAgICAgICAgICAiY29uZGl0aW9ucyI6IFsKICAgICAgICAgICAgeyJidWNrZXQiOiAiZ2lmYWZmZSJ9LAogICAgICAgICAgICBbInN0YXJ0cy13aXRoIiwgIiRrZXkiLCAiIl0sCiAgICAgICAgICAgIHsiYWNsIjogInByaXZhdGUifSwKCSAgICB7InN1Y2Nlc3NfYWN0aW9uX3N0YXR1cyI6ICIyMDAifSwKICAgICAgICAgICAgWyJzdGFydHMtd2l0aCIsICIkQ29udGVudC1UeXBlIiwgIiJdLAogICAgICAgICAgICBbImNvbnRlbnQtbGVuZ3RoLXJhbmdlIiwgMCwgNTI0Mjg4MDAwXQogICAgICAgICAgICBdCiAgICAgICAgICB9'),
                           ('key',key),
                           ('file',fp)]
		r = requests.post(post_url, files=payload)
	return r

post_url = 'https://gifaffe.s3.amazonaws.com/'
get_url = 'http://upload.gfycat.com/transcode/'

def getgifs():
        fnames=[]
        [fnames.extend(
                [(d+'/'+fn).decode('utf-8')
                 for fn in fns if fn[-4:]=='.gif'])
         for d,_,fns in walk('.')]
        return fnames

interrupted = 0
def inthandler(signum, frame):
        global interrupted
        if interrupted == 0:
                interrupted = 1
                l('...wrapping up...')
        else:
                sys.exit(0)

def shouldquit():
        global interrupted
        return interrupted > 0

if __name__ == '__main__':
        signal.signal(signal.SIGINT, inthandler)
        gifs=0
        webms=0
        queue = []

        def down(filename, key):
                global gifs, webms, queue
                request = requests.get(get_url + key)
                if (int(request.status_code) != 200):
                        print '\tError getting upload details'
                        print request.text
                        return
                json = request.json()
                if json.has_key('error'):
                        print '\tError(server): '+json['error']
                        return
                if json['webmUrl'] == None:
                        print '\tError(server): webm is not ready(?), postponing download'
                        queue.append((filename, key))
                        return
                l("\tDownloading >")
                try:
                        urlretrieve(json['webmUrl'], filename[:-4] + '.webm')
                        gifs+=int(json['gifSize'])
                        webms+=int(json['webmSize'])
                except:
                        print '\tError downloading file', sys.exc_info()
                        print json
                        return
                l("\tSaved! >")
                return

        for filename in getgifs():
                filename = filename
                l(filename + " \tUploading >")
                key = '%010d' % randint(0,9999999999) #alphanum
                request = create_request(filename, key)
                if (int(request.status_code) != 200):
                        print '\tError uploading file. Status Code: ' + str(request.status_code)
                        print request.text
                        continue
                l("\tUploaded >")
                down(filename, key)
                if shouldquit(): break

        queue_old = queue
        queue = []
        passn = 2
        while len(queue_old)>0:
                print 'pass #', passn
                for filename,key in queue_old:
                        down(filename, key)
                        if shouldquit(): queue=[]; break

        print 'Profit: %dM -> %dM' %(gifs/1024/1024, webms/1024/1024)
