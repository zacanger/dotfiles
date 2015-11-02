#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""LittleBlogger is just a small Python app for writting a static blog:

- you give it an 'In/' directory containing you posts written in some markup
  languages (supported are : reSt, Markdown).

  The first 4 lines of each post file will be parsed as they contain each
  post:

  *  [tit] Post Title [/tit]
  *  [date] Post Date (year month day hour minute)[/date]
  *  [tags] Post Tags [/tags]
  *  [markup] Post Markup Language [/markup]

- transfert its contents to FTP;


TODO:
-----

- Encoding problems ;
- Line endings ;
- css directory must be created if it dose not exists.
"""

import os
import glob
import codecs
import re
import datetime

## ConfigParser
import ConfigParser

## RSS2Gen
import PyRSS2Gen

## pygments
import RegisterPygment

## docutils
from docutils.core import publish_parts

## markdown
import markdown

## mako templates
from mako.template import Template
from mako.lookup import TemplateLookup

## FTP support
from ftplib import FTP

## ----- blogManager --------------------------------------------------------
class blogManager(object):
    """This class is used to manage the Blog Posts.

    It retrieves all the posts from a given directory
    parse them one by one and then build a tags list
    from them with no double.
    """
    def __init__(self, postdir = '',parent=None):
        self.parent = parent

        self.postdir = postdir
        self.getInOutDirs()

        self.blogFiles = os.listdir(self._in)
        self.getPostListAndIds()

    ## Read the Blog's config file
    def readConf(self):

        config = ConfigParser.RawConfigParser()
        try:
            config.read(os.path.join(self.postdir,'blog.conf'))
        except:
            print "You don't have a blog.conf file inside your Blog directory."
            return

        away = config.get('Away', 'BlogHomePage')
        host = config.get('Away', 'Host')
        user = config.get('Away', 'User')
        passw = config.get('Away', 'Password')
        remote = config.get('Away', 'RemoteDir')

        return away,host,user,passw,remote


    ## Some methods for changing the current Blog directory
    def changePostDir(self, other_postdir):
        self.posts_list = []
        self.postdir = other_postdir
        self.getInOutDirs()
        self.blogFiles = os.listdir(self._in)
        self.getPostListAndIds()

    def getPostListAndIds(self):
        self.posts_list = self.getPosts()

        for i,p in enumerate(self.getPostByDate(self.posts_list,rev=False)) :
            p.realid = i+1

    ## In, Out and Templates directories setup
    def getInOutDirs(self):
        self._in = os.path.join(self.postdir,'In/')
        self._out = os.path.join(self.postdir,'Out/')
        self._static = os.path.join(self.postdir,'Static/')
        self._templates = os.path.join(self.postdir,'Templates/')

    ## Posts retrieving
    def getPosts(self):
        """Return the Posts list by date
        """
        posts = []
        for thePost in self.blogFiles:
            posts.append(Post(thePost, self))
        return self.getPostByDate(posts)

    def getPostByDate(self, postslist, rev=True):
        def keyDate(elt):
            return elt.postdate
        return sorted(postslist,key=keyDate,reverse=rev)

    ## Add/Sub Posts [Never used for the moment]
    def addPost(self,post):
        if post not in self.posts_list :
            self.posts_list.append(post)

    def removePost(self,post):
        if post not in self.posts_list :
            raise noExitingPostError(post)
        else:
            self.posts_list.remove(post)

    ## Rendering methods
    def render(self):
        """Save all the Posts to HTML according to the
        given templates wirtten in Mako.
        """
        for post in self.posts_list:
            print 'saving post %s'%post.title
            post.saveWithMako()

    def publish(self):
        print 'publishing your Blog in dir%s'%(self.postdir)
        for p in self.posts_list :
            p.getInfos()
        self.render()
        self.buildIndex()
        self.builTaggedPages()
        self.buildStaticPages()
        self.buildRss()

    def buildIndex(self):
        """Build the index Page of the site.
        The number of viewed Posts on this page is
        set inside the Mako template.
        """
        mylookup = TemplateLookup(directories=[''])
        my_tpl = Template(  filename=os.path.join(self._templates, 'Index.mako'),
                            lookup=mylookup,
                            input_encoding='utf-8',
                            output_encoding='utf-8')


        f = file(os.path.join(self._out,'index.html'),'w')
        f.write(my_tpl.render(  articles= self.posts_list,
                                tags = self.tags))
        f.close()

    def builTaggedPages(self):
        """Given a Tag object, builds a Page with all Posts
        relative to the given Tag.
        """
        for t in self.tags :

            post_list = t.get_posts

            mylookup = TemplateLookup(directories=[''])
            my_tpl = Template(  filename=os.path.join(self._templates,'Tagged.mako'),
                                lookup=mylookup,
                                input_encoding='utf-8',
                                output_encoding='utf-8')

            f = open( os.path.join(self._out, t.url), "w" )
            f.write(my_tpl.render(  cat=t.tagname,
                                    tagged=post_list,
                                    articles= self.posts_list,
                                    tags=self.tags))
            f.close()
        #print "j'ai sauvegarde %s postes_tagges"%(len(self.tags ))

    def buildStaticPages(self):
        """
        """
        chem = os.path.join(self._static,'*.rst')

        for filename in os.listdir(self._static) :
            print "filename=",filename
            f = codecs.open( os.path.join(self._static,filename), "r", "utf-8" )
            cont = f.read()
            contenu = publish_parts(cont, writer_name="html")["html_body"]
            f.close()

            mytemplate = Template(filename=os.path.join(self._templates,'Static.mako'), input_encoding='utf-8', output_encoding='utf-8')
            # taken on
            # http://xahlee.org/perl-python/split_fullpath.html
            (dirName, fileName) = os.path.split(filename)
            (fileBaseName, fileExtension)=os.path.splitext(fileName)

            f = file(os.path.join(self._out, '%s.html'%(fileBaseName)),'w')
            f.write(mytemplate.render(
                    static=contenu,
                    articles= self.posts_list,
                    tags=self.tags))
            f.close()

    def buildRss(self):
        """RSS 2.0 Generation
        """
        away,host,user,password,remote = self.readConf()
        p_items = [PyRSS2Gen.RSSItem(
             title = post.title,
             link = away + post.url,
             description = "Description ici",
             pubDate = post.postdate) \
             for post in self.posts_list]

        rss = PyRSS2Gen.RSS2(
        title = "Kib's Articles feed",
        link = away + "index.html",
        description = "Dernieres nouvelles de Kib ",
        lastBuildDate = datetime.datetime.now(),
        items = p_items)
        rss.write_xml(open(os.path.join(self._out,"kibmemo.xml"), "w"))

    ## Transfert the files to FTP
    def transferToFtp(self):
    #def transferToFtp(self, host = 'ftpperso.free.fr', user = 'kib2', password = 'leon69', host_dir='ShadesOfPy'):

        away,host,user,password,remote = self.readConf()
        print "DONNEES FTP=\n",away,host,user,password,remote

        print 'host=',host
        connect = FTP(host,user,password)

        # connexion's state
        state = connect.getwelcome()

        if remote:
            connect.sendcmd('CWD %s'%remote)

        allFiles = [t for t in os.listdir(self._out) if os.path.isfile(self._out+t)]
        cssFiles = [t for t in os.listdir(self._out + 'css/') ]

        for myfile in allFiles:
            fichier = myfile
            file = open(self._out + fichier, 'rb')
            (_, tail) = os.path.split(myfile)
            tail = unicode(tail).encode('utf-8')
            connect.storbinary('STOR '+ tail, file)
            file.close()
            #print "%s has been transfered successfully in directory %s\n...Bye!"%(tail, host_dir)
        connect.quit()

        connect = FTP(host,user,password)
        if remote:
            connect.sendcmd('CWD %s'%remote+'/css')
        for myfile in cssFiles:
            fichier = myfile
            file = open(self._out + 'css/' + fichier, 'rb')
            (_, tail) = os.path.split(myfile)
            tail = tail.encode('utf-8')
            connect.storbinary('STOR '+ tail, file)
            file.close()
            #print "%s has been transfered successfully in directory %s\n...Bye!"%(tail, host_dir)
        print "All Files has been transfered successfully in directory %s\n...Bye!"%(remote)
        connect.quit()

    @property
    def tags(self):
        """We build the list of Tags here by looking at
        each Post instance, grabbing its string based tags list.

        From them, it builds a real Tags list instances.

        """
        thetags = []

        for post in self.posts_list :
            # iterate over each post pseudo-tag
            for tag in post.tags :
                #if tag not in thetags :
                thetagsNames = [k.tagname for k in thetags]
                #print 'Checking %s versus %s'%(tag.tagname,thetagsNames)
                if tag.tagname not in thetagsNames :
                    thetags.append(tag)

        ## Iterate over each tab and feeds it with
        ## corresponding posts
        for t in thetags:
            for p in self.posts_list:
                if t.tagname in [t1.tagname \
                    for t1 in p.tags if p not in t.posts]:
                    t.posts.append(p)

        return thetags
## ----- Post  --------------------------------------------------------------
class Post(object):
    pid = 0

    def __init__(self, filename = None, manager=None):
        self.manager = manager
        self.filename = filename

        ## note that post.contents is done inside self.getInfos()
        self.title, self.postdate, self.tags, self.extension = self.getInfos()

#        for tag in self.tags :
#            print 'Post %s Tagged %s'%(self.title, tag.tagname)
#            tag.posts.append(self)

        Post.pid += 1
        self.id = Post.pid

    def normalise_name(self,tname):
        return tname.strip().replace(' ', '_')

    def getInfos(self):
        """ Given a filename, parse the document to retrieve :

        - post title
        - post date
        - post tags
        - post markup [optioanl, reSt by default]
        """

        infos = ('tit','date','tags','markup')
        markup = {  'rest': '.rst',
                    'markdown' : '.md',
                }

        post_title, post_time, post_tags, post_markup = None, None, None, 'rest'

        f = open(self.manager._in + self.filename,'r')
        contents = f.readlines() # returns a list
        f.close()

        self.contents = ''.join(contents[4:]).decode('utf-8')

        self.toBeParsed = contents[0:4]

        ## We start by retrieving the beginning 5 lines
        ## of each Post file to get the title, date, tags and markup
        for el in infos :
            motif = re.compile(r'\[%s\](?P<conf>.*?)\[/%s\]'\
                    %(el,el),re.MULTILINE|re.UNICODE)
            for m in re.finditer(motif, ''.join(self.toBeParsed).decode('utf-8')):

                if el == 'tit' :
                    post_title = m.group('conf')
                elif el == 'date' :
                    t = m.group('conf').split()
                    post_time = datetime.datetime(  int(t[0]),
                                                    int(t[1]),
                                                    int(t[2]),
                                                    int(t[3]),
                                                    int(t[4])
                                                )
                elif el == 'tags':
                    post_tags = [Tag(t.encode('utf-8')) \
                                for t in m.group('conf').split(',')]
                    # now each tag in the post is added
                elif el == 'markup':
                    post_markup = m.group('conf')
        extension = markup[post_markup]

        return post_title, post_time, post_tags, extension

    @property
    def html_content(self):
        if self.extension == '.rst' :
            return publish_parts(self.contents,
                    writer_name="html")["html_body"]
        elif self.extension == '.md' :
            return markdown.markdown(self.contents,
                                    extensions= ['codehilite']
                                    )

    @property
    def get_tags(self):
        return ",".join([t.tagname for t in self.tags])

    @property
    def get_tags_one_by_one(self):
        return [t.tagname for t in self.tags]

    @property
    def get_time(self):
        temps= self.postdate.strftime('le %A %d %B %Y a %H h %M min')
        return temps.decode('utf-8')

    @property
    def url(self):
        return "%s.html"%(self.normalise_name(self.title))

    def __repr__(self):
        return "<Post(%r,%s)>" % (self.title, str(self.postdate))

    def saveWithMako(self):
        ## Va chercher le template mako et le remplis
        mylookup = TemplateLookup(directories=[self.manager._templates])
        my_tpl = Template(  filename=self.manager._templates + 'Detail.mako',
                            lookup=mylookup,
                            input_encoding='utf-8',
                            output_encoding='utf-8')

        #tit = normalise_name(self.title)
        f = open( self.manager._out + self.url, "w" )
        f.write(my_tpl.render(  p=self,
                                articles= self.manager.posts_list,
                                tags = self.manager.tags ))
        f.close()

## ----- Tag ----------------------------------------------------------------
class Tag(object):
    """A Post tag object.

    The Posts relatives to a given Tag will be
    filled inside the blogManager class.
    """
    def __init__(self, tagname):
        #self.tagname = tagname.decode('utf-8')

        self.tagname = tagname.decode('utf-8')
        self.posts = []

    def normalise_name(self,tname):
        return tname.strip().replace(' ', '_')

    @property
    def url(self):
        return "tagged_%s.html"%(self.normalise_name(self.tagname))

    @property
    def get_posts(self):
        return [(p.title, unicode(p.url)) for p in self.posts]

    @property
    def get_number_of_posts(self):
        return len(self.posts)

## ----- Main Programm  -----------------------------------------------------
def main():
    bm = blogManager('Blog3')
    bm.publish()
    bm.transferToFtp()

if __name__ == "__main__":
    main()


