import vim

# global variables
myBook = 0
langdict = {
            'python':  { 'lcom':  '#', 'filler':   '#', 'rcom':   '#', 'defs':   r'^def' },
            'perl':    { 'lcom':  '#', 'filler':   '#', 'rcom':   '#', 'defs':   r'^sub' },
            'vim':     { 'lcom':  '"', 'filler':   '"', 'rcom':   '"', 'defs':   r'^function' },
            'c':       { 'lcom':  '/*', 'filler':  '*', 'rcom':   '*/', 'defs':  r''},
            'cpp':     { 'lcom':  '//', 'filler':  '//', 'rcom':  '//', 'defs':  r''},
           }

class block():
    def __init__(self, fd, **option):
        self.length   = option['length']
        self.width    = option['width']
        self.lcom     = option['lcom']
        self.filler   = option['filler']
        self.rcom     = option['rcom']
        self.position = option['position']

        self.content = []
        line_loaded = 0
        while line_loaded <= self.length:
            line = fd.readline().decode('utf-8')
            # if reached the eof
            if not line: break
            # TODO
            # whitespace is halfwidth but count as a whole character
            line = line.rstrip('\r\n')
            # insert a whitespace make sure the blank line not be omitted
            if len(line) == 0: line = " "
            p = 0
            while p < len(line):
                self.content.append(line[p:p+self.width])
                line_loaded += 1
                p += self.width

    def commentize(self):
        output = self.lcom + self.filler * self.width * 2 + "\\n"
        for line in self.content:
            output += "{0} {1}\\n".format(self.filler, line.encode('utf-8'))
        output += self.filler * self.width * 2 + self.rcom + "\\n"
        return output

class page():
    def __init__(self, fd, **option):
        self.length        = option['length']
        self.width         = option['width']
        self.defs          = option['defs']
        self.current_block = 0
        self.blocks      = []

        self.anchors = []
        (o_line, o_col) = (vim.eval("line('.')"), vim.eval("col('.')"))
        vim.command("call cursor('1', '1')")
        while 1:
            anchor = int(vim.eval("search('{0}', 'W')".format(self.defs)))
            if anchor == 0: break
            self.anchors.append(anchor)
        # TODO
        # if there is no anchor, need extra solution

        # recover the cursor position
        vim.command("call cursor('{0}', '{1}')".format(o_line, o_col))

        for a in range(len(self.anchors)):
            if a == 0:
                option['position'] = self.anchors[a]
            else:
                option['position'] += self.anchors[a] - self.anchors[a-1] + len(self.blocks[-1].content) + 2
            new_block = block(fd, **option)
            if not new_block.content: break

            self.blocks.append(new_block)

    def render(self):
        # blocks may less than anchors
        for a in range(len(self.anchors)):
            if a >= len(self.blocks): break

            content = self.blocks[-a-1].commentize()
            # escape '"' as a string
            for char in '"':
                content = content.replace(char, '\\'+char)

            # insert blocks in descending order
            # otherwise the line numbers will mess
            anchor = self.anchors[-a-1]

            command = 'silent! {0}put! ="{1}"'.format(anchor, content)
            # escape '|' and '"' as argument for 'put' command
            for char in '|"':
                command = command.replace(char, '\\'+char)

            # let 'modified' intact
            o_modified = vim.eval('&modified')
            vim.command(command)
            vim.command('let &modified={0}'.format(o_modified))

            # set cursor to first block
            self.current_block = -1
            self.nextBlock()

    def clear(self):
        # blocks may less than anchors
        for a in range(len(self.anchors)):
            if a >= len(self.blocks): break
            anchor = self.anchors[a]
            block = self.blocks[a]
            crange = "{0},{1}".format(anchor, anchor+len(block.content)+1)

            command = "silent! {0}delete _".format(crange)

            # let 'modified' intact
            o_modified = vim.eval('&modified')
            vim.command(command)
            vim.command('let &modified={0}'.format(o_modified))

    def nextBlock(self):
        if self.current_block < len(self.blocks)-1:
            self.current_block += 1
            cb = self.blocks[self.current_block]
            midblock = cb.position + (len(cb.content) + 1)//2
            vim.command("normal {0}z.".format(midblock))
            return True
        else:
            return False

    def preBlock(self):
        if self.current_block > 0:
            self.current_block -= 1
            cb = self.blocks[self.current_block]
            midblock = cb.position + (len(cb.content) + 1)//2
            vim.command("normal {0}z.".format(midblock))
            return True
        else:
            return False

class book():
    def __init__(self, path, **option):
        self.fd           = open(path, 'r')
        self.pages        = []
        self.current_page = -1
        self.on_show      = 0
        self.length       = option['length']
        self.width        = option['width']

        # define commenters
        filetype = vim.eval("&filetype")
        if filetype in langdict:
            self.lcom   = langdict[filetype]['lcom']
            self.filler = langdict[filetype]['filler']
            self.rcom   = langdict[filetype]['rcom']
        else:
            self.lcom = vim.eval(r"substitute(&commentstring, '\([^ \t]*\)\s*%s.*', '\1', '')")
            # TODO
            # determine how to define filler
            self.filler = vim.eval(r"substitute(&commentstring, '\([^ \t]*\)\s*%s.*', '\1', '')")
            self.rcom = vim.eval(r"substitute(&commentstring, '.*%s\s*\(.*\)', '\1', 'g')")

        # define statement
        self.defs = langdict[filetype]['defs']

    def nextPage(self):
        option = {
                'length' : self.length,
                'width'  : self.width,
                'lcom'   : self.lcom,
                'filler' : self.filler,
                'rcom'   : self.rcom,
                'defs'   : self.defs,
                }
        new_page = page(self.fd, **option)

        # if reached the end
        if not new_page.blocks:
            return self.pages[self.current_page]

        self.pages.append(new_page)
        self.current_page += 1
        return self.pages[self.current_page]

    def prePage(self):
        if self.current_page == -1:
            return
        elif self.current_page == 0:
            return self.pages[self.current_page]

        self.current_page -= 1
        return self.pages[self.current_page]

    def render(self):
        if self.on_show: return
        page = self.pages[self.current_page]
        page.render()
        self.on_show = 1

    def clear(self):
        if not self.on_show: return
        page = self.pages[self.current_page]
        page.clear()
        self.on_show = 0

def CRopen(path):
    path = vim.eval('a:path')
    option = {
            'length' : int(vim.eval('g:creader_lines_per_block')),
            'width'  : int(vim.eval('g:creader_chars_per_line')),
            }

    global myBook
    # clear previous book
    if myBook != 0: CRclear()
    myBook = book(path, **option)
    CRnextpage()

def CRnextpage():
    myBook.clear()
    myBook.nextPage()
    myBook.render()

def CRprepage():
    myBook.clear()
    myBook.prePage()
    myBook.render()

def CRnextblock():
    if myBook.pages[myBook.current_page].nextBlock():
        pass
    else:
        CRnextpage()

def CRpreblock():
    if myBook.pages[myBook.current_page].preBlock():
        pass
    else:
        CRprepage()

def CRclear():
    myBook.clear()
