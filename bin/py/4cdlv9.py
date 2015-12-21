#initial release Nov. 5, 2009
#v6 release Jan. 20, 2009
#http://cal.freeshell.org

import os.path
import re
import string
import sys
import time
import urllib
import urllib2



#Regular Expressions
imgurl = re.compile('\w+\.4chan\.org/\w+/src/\d+\.(?:jpg|gif|png|jpeg)')
thumb = re.compile('thumbs\.4chan\.org/\w+/thumb/\d+s\.(?:jpg|gif|png|jpeg)')
thumbname = re.compile("\d+s\.(?:jpg|gif|png|jpeg)")
imgurl2 = re.compile('http://\w+\.4chan\.org/\w+/src/')
picname = re.compile('\d+\.(?:jpg|gif|png|jpeg)')
tname = re.compile('/\d+')
rs = re.compile('http://rapidshare.com/files/\d+/.*\.(?:rar|zip|avi|wmv|part\d+\.rar|\d+)''|http://megaupload.com/?d=........''|http://megaporn.com/?d=........')

#Initiate Variables
thread = sys.argv[1] #get argument from initial command: this is the thread address
directory = sys.argv[2]
delay = sys.argv[3]
arch = int(sys.argv[4])

#Setup headers to spoof Mozilla
dat = None
ua = "Mozilla/5.0 (Windows; U; Windows NT 5.2; en-US; rv:1.9.1.4) Gecko/20091007 Firefox/3.5.4"
head = {'User-agent': ua}

errorcount = 0


#Create directory name
dirname = str(tname.findall(thread))

#Clean directory name
dirname = dirname.replace('[', '')
dirname = dirname.replace(']', '')
dirname = dirname.replace(chr(39), '')
dirname = dirname.replace(chr(92), '')
dirname = dirname.replace(chr(47), '')
dname = dirname
dirname = directory + chr(92) + dirname

print "Downloading to: " + dirname
#Create directorty if it doesn't exist
if not os.path.exists(dirname):
    os.mkdir(dirname)
if arch == 1:
    if not os.path.exists(dirname + chr(92) + "thumb"):
        os.mkdir(dirname + chr(92) + "thumb")
    
        
#Add \ to directory name for image saving        
dirname = dirname + chr(92)

#Start
while 1:
    print "Scraping: " + thread

#Get page
    req = urllib2.Request(thread, dat, head)
    try:
        response = urllib2.urlopen(req)
    except urllib2.HTTPError, e:
        if errorcount < 1:
            errorcount = 1
            print "Request failed, retrying in " + delay + " seconds"
            time.sleep(int(delay))
            response = urllib2.urlopen(req)
    except urllib2.URLError, e:
        if errorcount < 1:
            errorcount = 1
            print "Request failed, retrying in " + delay + " seconds"
            time.sleep(int(delay))
            response = urllib2.urlopen(req)

    msg = response.read()
    errorcount = 0
    
#Find all pictures and rapidshare links
    kwl = imgurl.findall(msg)
    rsl = rs.findall(msg)
    tl = thumb.findall(msg)

#Save pictures
    for item in list(set(kwl)): #list(set(kwl)) removes duplicates
#Clean image URL and clean file name
        filename = picname.findall(str(item))
        fname = str(filename)
        fname = fname.replace('[', '')
        fname = fname.replace(']', '')
        fname = fname.replace(chr(39), '')
#Download the image if it doesn't exists
        if not os.path.isfile(dirname + fname):
            print "Downloading: " + str(item)
            try:
                urllib.urlretrieve("https://" + str(item), dirname + str(fname))
                time.sleep(0.25)
            except urllib.ContentTooShortError:
                print "Image download failed, retrying in " + int(delay)/4 + " seconds"
                time.sleep(int(delay)/4)
                urllib.urlretrieve("https://" + str(item), dirname + str(fname))
                time.sleep(0.25)
        else:
            print str(fname) + " Exists... Trying next file."


#Download thumbnails
    if arch == 1:
        for item3 in list(set(tl)): #list(set(kwl)) removes duplicates
    #Clean image URL and clean file name
            filename = thumbname.findall(str(item3))
            fname = str(filename)
            fname = fname.replace('[', '')
            fname = fname.replace(']', '')
            fname = fname.replace(chr(39), '')
    #Download the image if it doesn't exists
            if not os.path.isfile(dirname + "thumb" + chr(92) + fname):
                print "Downloading thumbnail: " + str(item3)
                try:
                    urllib.urlretrieve("https://" + str(item3), dirname + "thumb" + chr(92) + str(fname))
                    time.sleep(0.25)
                except urllib.ContentTooShortError:
                    print "Thumbnail download failed, retrying in " + int(delay)/4 + " seconds"
                    time.sleep(int(delay)/4)
                    urllib.urlretrieve("https://" + str(item3), dirname + "thumb" + chr(92) + str(fname))
                    time.sleep(0.25)
            else:
                print str(fname) + "(thumbnail) Exists... Trying next file."
        

#Replace URLs with local images locations
    outp = open(dirname + dname + ".html", "w")

    for item3 in list(set(kwl)):
        filename = picname.findall(str(item3))
        fname = str(filename)
        fname = fname.replace('[', '')
        fname = fname.replace(']', '')
        fname = fname.replace(chr(39), '')
        fname = fname.replace("/", "")
        msg = msg.replace(str(item3), fname)
        strr = str(item3)
        strr = strr.replace("https:", "")
        msg = msg.replace(strr, fname)
        msg = msg.replace("//" + fname, fname)

    if arch == 1:
        treg = re.compile("//\d\.thumbs.4chan.org/.?/")
        for item4 in list(set(tl)):
            filename = thumbname.findall(str(item4))
            fname = str(filename)
            fname = fname.replace('[', '')
            fname = fname.replace(']', '')
            fname = fname.replace(chr(39), '')
            #msg = msg.replace(str(item4), chr(34) + "thumb" + chr(92) + fname + chr(34))
            msg = msg.replace("http:\\iqdb.org/?url=" + str(item4), chr(34) + "thumb" + chr(92) + fname + chr(34))
            msg = msg.replace("http://www.google.com/searchbyimage?image_url=" + str(item4), chr(34) + "thumb" + chr(92) + fname + chr(34))
            strr = str(item4)
            #strr = strr.replace("https:
            msg = re.sub(treg, "", msg)
    outp.write(msg)
    outp.close()


#Save download links to a text file if they exist
    if not rs.search(msg):
        print "Nothing to download."
    else:
        print "Downloads found!"
        foutrs = open(dirname + "dl.txt", "w")
        for item2 in list(set(rsl)):
            foutrs.write(str(item2) + "\n")
        foutrs.close()

#Wait to execute code again
    print "Waiting " + delay + " seconds before retrying"
    time.sleep(int(delay))