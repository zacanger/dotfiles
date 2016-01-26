# -*- coding: utf-8 -*-
import vim     # actually vim is imported in commentreader.vim
import sys
import urllib
import urllib2
import urlparse
import time
import json
import oauth2  # actually oauth2 is imported in commentreader.vim
import logging

# global variables {{{

CR_Langdict = {
            'python':      { 'prefix':  '#',  'filler':  '#',  'suffix':  '#',  'defs':  r'^def' },
            'perl':        { 'prefix':  '#',  'filler':  '#',  'suffix':  '#',  'defs':  r'^sub' },
            'vim':         { 'prefix':  '"',  'filler':  '"',  'suffix':  '"',  'defs':  r'^function' },
            'javascript':  { 'prefix':  '//', 'filler':  '//', 'suffix':  '//', 'defs':  r'^function' },
            'c':           { 'prefix':  '/*', 'filler':  '*',  'suffix':  '*/', 'defs':  r''},
            'cpp':         { 'prefix':  '//', 'filler':  '//', 'suffix':  '//', 'defs':  r''},
           }

CR_Instance = {}

# logging setting
if int(vim.eval("g:creader_debug_mode")):
    logging.basicConfig(filename=vim.eval("g:creader_log_file"), level=logging.DEBUG, format='%(asctime)s %(message)s')
else:
    logging.basicConfig(filename=vim.eval("g:creader_log_file"), level=logging.WARNING, format='%(asctime)s %(message)s')

# }}}

# Interface {{{

def CRopen(bufnum, cls_name, *argument):
    try:
        if bufnum not in CR_Instance:
            CR_Instance[bufnum] = CommentReader()
        cls = getattr(sys.modules[__name__], cls_name)
        CR_Instance[bufnum].openContent(cls, *argument)
    except Exception as e:
        logging.exception('')
        vim.command("echom '{0}'".format(e))

def CRoperation(bufnum, op, *argument):
    if bufnum in CR_Instance:
        instance = CR_Instance[bufnum]
        try:
            getattr(instance, op)(*argument)
        except Exception as e:
            logging.exception('')
            vim.command("echom '{0}'".format(e))
    else:
        vim.command("echom 'No contents have been opened!'")

def CRclose(bufnum):
    if bufnum in CR_Instance:
        CR_Instance[bufnum].hide()
        del CR_Instance[bufnum]
    else:
        vim.command("echom 'No contents have been opened!'")

# }}}

# Main Class {{{

class CommentReader():
    def __init__(self):
        self.option  = {
                'line_num': int(vim.eval('g:creader_lines_per_block')),
                'line_len': int(vim.eval('g:creader_chars_per_line')),
                'session_file': vim.eval('g:creader_session_file'),
                'debug_mode': int(vim.eval('g:creader_debug_mode')),
                'log_file': vim.eval('g:creader_log_file'),
                }

        self.head       = None # the pointer to current content
        self.content    = {}   # self.content is a dict of Content instances. example: self.content = { 'Twitter': Twitter(), 'Weibo': Weibo(), ... }
        self.session    = self.loadSession()
        self.view       = View(self.option)

        self.base       = 0
        self.offset     = 0
        self.on_display = False

    # opens

    def openContent(self, cls, *argument):
        # Content
        type = cls.__name__
        if type not in self.content:
            self.content[type] = cls(self.session.get(type, {}), self.option)

        # Initialization
        self.head   = self.content[type]
        if argument or not self.head.ready():
            self.head.prepare(*argument)
        self.base   = 0
        self.offset = 0

        # View
        if self.head.ready():
            self.view.refreshAnchor()
            self.show()
            self.first()

    def refresh(self):
        self.head.refresh()

        self.base   = 0
        self.offset = 0

        self.show()
        self.first()

    # session

    def saveSession(self):
        for name in self.content:
            self.session[name] = self.content[name].saveSession()
        try:
            fp = open(self.option['session_file'], 'w+')
            json.dump(self.session, fp)
        except:
            # TODO: do something
            pass

    def loadSession(self):
        try:
            fp = open(self.option['session_file'], 'r')
            return json.load(fp)
        except:
            return {}

    # views

    def toggle(self):
        if self.on_display:
            self.hide()
        else:
            self.show()

    def show(self):
        # clear first
        self.view.clear()

        # get content and render 
        # TODO: need to check the EOF
        raw_content_list = self.head.read(self.base, self.view.getAnchorNum())
        content_list = self.view.commentizeList(raw_content_list)
        self.view.render(content_list)

        # change maps if needed
        if not self.on_display: self._changeMap()

        self.on_display = True

    def hide(self):
        self.view.clear()

        # restore maps if needed
        if self.on_display: self._restoreMap()

        self.on_display = False

    # cursor moves

    def forward(self, seek=None):
        # TODO: return if self.base == MAX

        self.base += self.view.getAnchorNum()
        self.show()
        if seek is None:
            self.first()
        else:
            self._seek(seek)

    def backward(self, seek=None):
        if self.base == 0:
            return

        self.base -= self.view.getAnchorNum()
        if self.base < 0:
            self.base = 0
        self.show()
        if seek is None:
            self.first()
        else:
            self._seek(seek)

    def first(self):
        self._seek(self.base)

    def last(self):
        self._seek(self.base + self.view.getAnchorNum - 1)

    def next(self):
        offset = self.offset + 1
        if offset >= self.view.getAnchorNum():
            self.forward(self.base + offset)
        else:
            self._seek(self.base + offset)

    def previous(self):
        offset = self.offset - 1
        if offset < 0:
            self.backward(self.base + offset)
        else:
            self._seek(self.base + offset)

    def _changeMap(self):
        self.map_bak = {}
        for key in "hjklrq":
            self.map_bak[key] = vim.eval("maparg('{0}','n')".format(key))

        vim.command("nnoremap <buffer><silent> l :CRforward<CR>")
        vim.command("nnoremap <buffer><silent> h :CRbackward<CR>")
        vim.command("nnoremap <buffer><silent> k :CRprevious<CR>")
        vim.command("nnoremap <buffer><silent> j :CRnext<CR>")
        vim.command("nnoremap <buffer><silent> r :CRrefresh<CR>")
        vim.command("nnoremap <buffer><silent> q :CRhide<CR>")

    def _restoreMap(self):
        for key in self.map_bak:
            vim.command("nunmap <buffer> {0}".format(key))
            if self.map_bak[key]: vim.command("nnoremap <buffer> {0} {1}".format(key, self.map_bak[key]))

    # index is the current node's index in all node's array
    # index = self.base + self.offset
    def _seek(self, index):
        self.offset = (index - self.base) % self.view.getAnchorNum()
        self.view.pointTo(self.offset)

# }}}

# View Classes {{{

class View():
    def __init__(self, option):
        # user defined options
        self.lineLen = option['line_len']
        self.lineNum = option['line_num']

        # define commenter
        filetype = vim.eval("&filetype")
        if filetype in CR_Langdict:
            self.prefix = CR_Langdict[filetype]['prefix']
            self.filler = CR_Langdict[filetype]['filler']
            self.suffix = CR_Langdict[filetype]['suffix']
        else:
            raise Exception('Sorry, this language is not supported.')

        # define declaration reserved word
        self.defs = CR_Langdict[filetype]['defs']

        # define anchors
        self.anchors = []
        self.refreshAnchor()

    # anchors

    def getAnchorNum(self):
        return len(self.anchors)

    def refreshAnchor(self):
        # clear comment first
        self.clear()

        # reassign anchors
        self.anchors = []

        # save original cursor positon
        (line_bak, col_bak) = (int(vim.eval("line('.')")), int(vim.eval("col('.')")))
        vim.command("call cursor('1', '1')")
        pre_anchor = None
        pre_posi = 0
        while 1:
            posi = int(vim.eval("search('{0}', 'W')".format(self.defs)))
            if posi == 0: break
            new_anchor = Anchor(posi - pre_posi, pre_anchor)
            self.anchors.append(new_anchor)
            pre_posi = posi
            pre_anchor = new_anchor
        # restore cursor position
        vim.command("call cursor('{0}', '{1}')".format(line_bak, col_bak))

        if len(self.anchors) == 0:
            raise Exception('Sorry, there is no place for comment.')

    # show or hide contents

    def render(self, string_list):
        (line_bak, col_bak) = (int(vim.eval("line('.')")), int(vim.eval("col('.')")))

        for (anchor, content) in zip(self.anchors, string_list):
            # bind content and anchor
            anchor.bind(content)

            # escape '"' as a string
            for char in '"':
                content = content.replace(char, '\\'+char)

            # render content in vim
            abs_posi = anchor.getAbsPosition()
            command = 'silent! {0}put! ="{1}"'.format(abs_posi, content)
            # escape '|' and '"' as argument for 'put' command
            for char in '|"':
                command = command.replace(char, "\\"+char)
            # make 'modified' intact
            modified_bak = vim.eval('&modified')
            vim.command(command)
            vim.command('let &modified={0}'.format(modified_bak))

        vim.command("call cursor('{0}', '{1}')".format(self.o2cPosition(line_bak), col_bak))

    def clear(self):
        (line_bak, col_bak) = (int(vim.eval("line('.')")), int(vim.eval("col('.')")))
        line_num = self.c2oPosition(line_bak) # c2oPosition should be called before anchor.unbind

        for anchor in self.anchors:
            if anchor.size > 0:
                # clear content from buffer
                abs_posi = anchor.evalAbsPosition()
                range = "{0},{1}".format(abs_posi, abs_posi + anchor.size - 1)
                command = "silent! {0}delete _".format(range)
                # make 'modified' intact
                modified_bak = vim.eval('&modified')
                vim.command(command)
                vim.command('let &modified={0}'.format(modified_bak))
            else:
                pass

            # unbind content and anchor
            anchor.unbind()

        vim.command("call cursor('{0}', '{1}')".format(line_num, col_bak))

    # cursor move

    def pointTo(self, n):
        anchor = self.anchors[n]
        position = anchor.getAbsPosition() + (anchor.size - 1)//2
        vim.command("normal {0}z.".format(position))

    def o2cPosition(self, o_line_num):
        offset = 0
        for anchor in self.anchors:
            if anchor.getAbsPosition() > o_line_num: break
            offset += anchor.size
        return o_line_num + offset

    def c2oPosition(self, c_line_num):
        offset = 0
        for anchor in self.anchors:
            if anchor.getAbsPosition() > c_line_num: break
            if c_line_num < anchor.getAbsPosition() + anchor.size:
                offset += c_line_num - anchor.getAbsPosition() + 1
            else:
                offset += anchor.size
        return c_line_num - offset

    # content formatter

    def commentize(self, str):
        output = self.prefix + self.filler * self.lineLen * 2 + "\\n"
        for l in str.split("\n"):
            output += "{0} {1}\\n".format(self.filler, l.encode('utf-8'))
        output += self.filler * self.lineLen * 2 + self.suffix + "\\n"
        return output

    def commentizeList(self, str_list):
        return [self.commentize(str) for str in str_list]

class Anchor():
    def __init__(self, rel_posi, pre_anchor):
        self.rel_posi   = rel_posi
        self.abs_posi   = -1
        self.size       = 0
        self.pre_anchor = pre_anchor

    def evalAbsPosition(self):
        if self.pre_anchor is None:
            self.abs_posi = self.rel_posi
            return self.abs_posi
        else:
            self.abs_posi = self.pre_anchor.evalAbsPosition() + self.pre_anchor.size + self.rel_posi
            return self.abs_posi

    # Warning: if you need EXACT position, call evalAbsPosition instead
    def getAbsPosition(self):
        if self.abs_posi != -1:
            return self.abs_posi
        else:
            return self.evalAbsPosition()

    def bind(self, str):
        self.abs_posi = self.evalAbsPosition()
        self.size = str.count("\\n")

    def unbind(self):
        self.abs_posi = -1
        self.size = 0

# }}}

# Content Classes {{{

class Content():
    def read(self, index, amount):
        items = self.getItem(index, amount)
        return [i.content(self.option) for i in items]

    def prepare(self):
        pass

    def ready(self):
        pass

    def getItem(self):
        pass

    def refresh(self):
        self.items = []

    def saveSession(self):
        pass

    def loadSession(self):
        pass

class Item():
    def Content(self):
        pass

# Content: Book {{{

class Book(Content):
    def __init__(self, session, option):
        self.items  = []
        self.option = option
        (self.path, self.fp) = self.loadSession(session)

    def prepare(self, path=None):
        if self.ready():
            return
        else:
            if path:
                self.path = path
                self.fp   = open(path, 'r')
            else:
                raise Exception("Need a file to open!")

    def ready(self):
        if self.fp:
            return True
        else:
            return False

    def getItem(self, index, amount):
        output = []
        for i in range(index, index + amount):
            if i < len(self.items):
                output.append(self.items[i])
            else:
                item = Page(self.fp, self.option)
                if item.content == "": break
                self.items.append(item)
                output.append(item)
        return output

    def saveSession(self):
        return {'path': self.path}

    def loadSession(self, session):
        path = session.get('path', None)
        fp = open(path, 'r') if path else None
        return path, fp

class Page(Item):
    def __init__(self, fp, option):
        content = []
        line_loaded = 0
        while line_loaded <= option['line_num']:
            line = fp.readline().decode('utf-8')
            if not line: break
            line = line.rstrip('\r\n')
            if len(line) == 0: line = " "
            p = 0
            while p < len(line):
                content.append(line[p:p+option['line_len']])
                line_loaded += 1
                p += option['line_len']

        self.text = "\n".join(content)

    def content(self, option):
        return self.text

# }}}

# Content: Weibo {{{

class Weibo(Content):
    def __init__(self, session, option):
        self.items      = []
        self.option     = option
        self.token_info = self.loadSession(session)

    def reqAuthPage(self):
        url          = 'https://api.weibo.com/oauth2/authorize'
        client_id    = '1861844333'
        redirect_uri = 'https://api.weibo.com/oauth2/default.html'

        vim.command("let @+='{0}?client_id={1}&redirect_uri={2}'".format(url, client_id, redirect_uri))
        vim.command("echo 'open url in your clipboard'")

    def reqAccessToken(self, auth_code):
        client_id     = '1861844333'
        client_secret = '160fcb0ca75b22e35c644f8758e279c1'
        redirect_uri  = 'https://api.weibo.com/oauth2/default.html'

        url = 'https://api.weibo.com/oauth2/access_token'
        params = {
                'client_id': client_id,
                'client_secret': client_secret,
                'grant_type': 'authorization_code',
                'redirect_uri': redirect_uri,
                'code': auth_code,
                }

        try:
            logging.debug("request: " + url + ' POST: ' + urllib.urlencode(params))
            res = urllib2.urlopen(url, urllib.urlencode(params))
            token_info = json.load(res)
            logging.debug("response: " + str(token_info))
            logging.debug("access_token: " + token_info['access_token'])
        except:
            # TODO: error handle
            logging.exception('')

        self.token_info = token_info
        return token_info

    def _pullTweets(self):
        url = 'https://api.weibo.com/2/statuses/home_timeline.json'
        params = {
                'access_token': self.token_info['access_token'],
                'count': 20,
                'page': 1,
                }
        if len(self.items) != 0:
            params['max_id'] = self.items[-1].id - 1

        try:
            logging.debug("request: " + url + '?' + urllib.urlencode(params))
            res = urllib2.urlopen(url + '?' + urllib.urlencode(params))
            raw_timeline = json.load(res)
            logging.debug("response: " + str(raw_timeline))
        except:
            # TODO: error handle
            logging.exception('')

        for raw_tweet in raw_timeline['statuses']:
            self.items.append(Weebo(raw_tweet))

        return self.items

    def getItem(self, index, amount):
        while index + amount > len(self.items):
            self._pullTweets()
        return self.items[index:index+amount]

    def prepare(self, auth_code=None):
        if self.ready():
            return
        else:
            if auth_code:
                self.reqAccessToken(auth_code)
            else:
                self.reqAuthPage()

    def ready(self):
        if self.token_info.get('access_token', ''):
            return True
        else:
            return False

    def saveSession(self):
        return self.token_info 

    def loadSession(self, token_info):
        return token_info

class Weebo(Item):
    def __init__(self, raw_weebo):
        self.id = long(raw_weebo['id'])
        self.author = raw_weebo['user']['name']
        self.text = raw_weebo['text']

    def content(self, option):
        return self.author + ": " + self.text + "\n"

# }}}

# Content: Twitter {{{

class Twitter(Content):
    def __init__(self, session, option):
        # instance variables
        self.items        = []
        self.option       = option
        self.access_token = self.loadSession(session)

        # oauth2
        consumer_key    = "XmUMZJditvgoMPhomEv9Q"
        consumer_secret = "FcYAmssSLy5vGusg8yPjqc8zLqwOAUoQxwQuKdjDg"
        self.consumer = oauth2.Consumer(consumer_key, consumer_secret)

        if self.ready():
            token = oauth2.Token(self.access_token['oauth_token'], self.access_token['oauth_token_secret'])
            self.client = oauth2.Client(self.consumer, token)
        else:
            self.client = oauth2.Client(self.consumer)

    def reqAuthPage(self):
        request_token_url = 'https://api.twitter.com/oauth/request_token'
        authorize_url     = 'https://api.twitter.com/oauth/authorize'

        try:
            res, content = self.client.request(request_token_url, "GET")
        except:
            logging.exception('')

        request_token = dict(urlparse.parse_qsl(content))
        vim.command("let @+='{0}?oauth_token={1}'".format(authorize_url, request_token['oauth_token']))
        vim.command("echo 'open url in your clipboard'")

        self.request_token = request_token

    def reqAccessToken(self, PIN):
        access_token_url  = 'https://api.twitter.com/oauth/access_token'

        token = oauth2.Token(self.request_token['oauth_token'], self.request_token['oauth_token_secret'])
        token.set_verifier(PIN)
        self.client = oauth2.Client(self.consumer, token)

        res, content = self.client.request(access_token_url, "POST")

        # save Access Token
        self.access_token = dict(urlparse.parse_qsl(content))

        # set client's token to Access Token
        token = oauth2.Token(self.access_token['oauth_token'], self.access_token['oauth_token_secret'])
        self.client = oauth2.Client(self.consumer, token)

    def _pullTweets(self):
        url = 'http://api.twitter.com/1.1/statuses/home_timeline.json'
        params = {
                'count': 20,
                }
        if len(self.items) != 0:
            params['max_id'] = self.items[-1].id - 1

        res, content = self.client.request(url + '?' + urllib.urlencode(params), "GET")
        try:
            raw_timeline = json.loads(content)
        except:
            logging.exception('')

        for raw_tweet in raw_timeline:
            self.items.append(Tweet(raw_tweet))

        return self.items

    def prepare(self, PIN=None):
        if self.ready():
            return
        else:
            if PIN:
                self.reqAccessToken(PIN)
            else:
                self.reqAuthPage()

    def ready(self):
        if self.access_token.get('oauth_token', ''):
            return True
        else:
            return False

    def getItem(self, index, amount):
        while index + amount > len(self.items):
            self._pullTweets()
        return self.items[index:index+amount]

    def saveSession(self):
        return self.access_token

    def loadSession(self, access_token):
        return access_token

class Tweet(Item):
    def __init__(self, raw_tweet):
        self.id = long(raw_tweet['id'])
        self.author = raw_tweet['user']['name']
        self.text = raw_tweet['text']

    def content(self, option):

        return self.author + ": " + self.text + "\n"

# }}}

# Content: Douban {{{
# }}}

# Content: Facebook {{{
# }}}

# }}}

# vim: set foldmarker={{{,}}} foldlevel=0 foldmethod=marker spell:
