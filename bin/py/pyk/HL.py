import os
import glob
import xml.etree.cElementTree as ET
from PyQt4 import QtCore, QtGui

APPLIREP = os.getcwd()
SYNTAXES = os.path.join(APPLIREP, 'Schemes/')

def getNameExtensionsDic(motif='*_scheme.xml',
                        chemin_rech = SYNTAXES,
                        sep_chemin = os.pathsep):
    """Parse all scheme files and returns a dictionnary whose keys are :
    - the name of a langage : string
    and the values are :
    - his extension(s) : tuple

    Example of use :
    ----------------

    print getNameExtensionsDic('*_scheme.xml', r'/Schemes')

    will return i.e :

    {'Python': ['py', 'pyw'], 'LaTeX': ['tex'], 'Lout': ['lout', 'lt', 'ld']}

    ## TODO :
    What if some langages define the same extension ?
    ie txt files maybe used with reSt, BBCode, etc.
    """
    nameExtensions = {}
    for chemin in chemin_rech.split(sep_chemin):
        for corresp in glob.glob(os.path.join(chemin, motif)):
                doc = ET.parse(corresp)
                element = doc.findall("scheme")
                for ele in element :
                    nameExtensions[ele.attrib['name']] = tuple(ele.attrib['extensions'].split(';'))
    return nameExtensions

class simpleContext(object):
    """Handle simple regexp based rules
    """
    def __init__(self,attr={},start=None):
        self.attributes = attr
        self.start = start
        self.isComment = False
        self.not_in = []

        ## the regexp is non greedy if 'mini' is set to True
        if 'mini' in self.attributes.keys():
            self.start.setMinimal(True)

        ## 'comment' is a particular case
        if 'comment' in self.attributes.keys():
            self.isComment = True

        ## will not be highlighted inside some excluding rules
        if 'not_in' in self.attributes.keys():
            #self.not_in = QtCore.QStringList(unicode(self.attributes['not_in'].split()))
            self.not_in = unicode(self.attributes['not_in'].split())


    def getFormat(self):
        return self.attributes['format']

class listContext(object):
    """Handle simple regexp based rules
    """
    def __init__(self,attr={},start=None):
        self.attributes = attr
        self.pref = None
        self.bound = True
        if 'prefix' in self.attributes.keys():
            self.pref = unicode(self.attributes['prefix'])
        if 'bounded' in self.attributes.keys():
            self.bound = False
        self.start = QtCore.QRegExp(unicode("|".join(self.constructRegExp(start,self.bound))))
        #self.start = "\\b(" + "|".join(start.split()) + ")\\b"

    def getFormat(self):
        return self.attributes['format']

    def constructRegExp(self,names,bounded=True):
        j = []
        for k in (names).split() :
            if self.pref :
                k = self.pref + k
            if bounded:
                j.append( "\\b" + k + "\\b")
            else:
                j.append( k )
        return j

class blockContext(object):
    """Handle the state based rules
    """

    def __init__(self,attr={},start=None, stop=None, esc=False, state = -1):
        ## @param attributes : dictionnary whose keys are
        ##  'stayOnLine': True or False(default)
        ##  'id': of type string
        ##  'format': of type string
        ## @params start and stop : type string
        ## @param escape : type string
        ## @param exclusive : True(default) or False
        self.attributes = attr
        self.start = start
        self.stop = stop
        self.escape = esc
        self.isExclusive = True
        self.stayOnLine = attr['stayOnLine']
        self.id = attr['id']
        self.format = attr['format']
        self.state = state
        self.delta = 0

        try:
            self.isComment = attr['comment']
        except:
            self.isComment = False

    def getFormat(self):
        return self.attributes['format']

def getAttributesFrom(el, attr_type,defaultval):
    d = el.attrib
    if not attr_type in d.keys():
        d[attr_type] = defaultval
    elif d[attr_type] in ('true','1','True'):
        d[attr_type] = True
    elif d[attr_type] in ('false','0','False'):
        d[attr_type] = False
    return d

def readRulesFromXML(file=None):
    try:
        doc = ET.parse(file)
    except:
        print 'Can\'t parse the %s file, maybe a syntax problem'%file
    iter = doc.getiterator()

    # different rule formats
    ctx = [] # context rules
    words = [] # words rules
    word = [] # simple regexp word

    ctx_ind = -1
    for element in iter:

        if  element.tag == 'context':
            ctx_ind += 1
            gr = blockContext(getAttributesFrom(element,"stayOnLine", False))
            for child in element:
                if child.tag == 'start':
                    gr.start = QtCore.QString(unicode(child.text))
                elif child.tag == 'stop':
                    gr.stop = QtCore.QString(unicode(child.text))
                    gr.isExclusive = getAttributesFrom(child, "exclusive", True)["exclusive"]
                elif child.tag == 'escape':
                    gr.escape = child.text
            gr.state = ctx_ind
            ctx.append(gr)

        # parse a list of words
        elif element.tag == 'words':
            sc = listContext(element.attrib,element.text)
            words.append(sc)

        # parse a simple word
        elif element.tag == 'word':
            sc = simpleContext(element.attrib,QtCore.QRegExp(element.text))
            word.append(sc)

    return (ctx,words,word)


def readFormatFromXML(file = SYNTAXES+r'/formats.qxf'):
    """Reads an XML file containing the formats definitions
    and build the QTextCharFormats from it
    """
    formats = {}
    doc = ET.parse(file)
    entries = doc.findall("formats/format")

    for entry in entries:
        f = QtGui.QTextCharFormat()
        f.setForeground(QtGui.QColor(entry.find("color").text))
        f.setFontItalic(bool(int(entry.find("italic").text)))
        f.setFontUnderline(bool(int(entry.find("underline").text)))
        if bool(int(entry.find("bold").text)) :
            f.setFontWeight(QtGui.QFont.Bold)
        formats[entry.attrib["id"]] = f
    return formats

#readRulesFromXML()

class genericHighlighter(QtGui.QSyntaxHighlighter):
    def __init__(self, parent, file=SYNTAXES+r'python_scheme.xml'):
        QtGui.QSyntaxHighlighter.__init__(self, parent)
        self.editor = parent
        #self.resetRules()
        self.formats = readFormatFromXML()
        self.ctx_rules, self.words_rules, self.word_rules = readRulesFromXML(file)
        self.cmt_rules = [f for f in self.word_rules if f.isComment]
        self.normal_rules = [f for f in self.word_rules if not f.isComment]

        # get the extensions dictionnary
        self.extensionsDic = getNameExtensionsDic()
        #print 'dico=',self.extensionsDic

    def changeRules(self, file=SYNTAXES+r'python_scheme.xml'):
        self.ctx_rules, self.words_rules, self.word_rules = readRulesFromXML(file)
        self.cmt_rules = [f for f in self.word_rules if f.isComment]
        self.normal_rules = [f for f in self.word_rules if not f.isComment]

    def resetRules(self):
        self.ctx_rules, self.words_rules, self.word_rules,self.formats = None,None,None,None

    def getNonCommentRules(self):
        # stayOnLine is False by defaut
        return [f for f in self.ctx_rules if not f.isComment]

    def getCommentRules(self):
        # stayOnLine is False by defaut
        return [f for f in self.ctx_rules if f.isComment]

    def getStartLineBased(self, rule):
        res = []
        for r in self.ctx_rules:
            if r.start != rule.stop :
                res.append(rule.stop)
        return res

    def getStatesFrom(self):
        return [s.state for s in self.getNonCommentRules()]

    def rehighlight(self):
        QtGui.QApplication.setOverrideCursor(QtGui.QCursor(QtCore.Qt.WaitCursor))
        #self.editor.sb.showMessage('I should rehighlight...please wait')
        QtGui.QSyntaxHighlighter.rehighlight(self)
        QtGui.QApplication.restoreOverrideCursor()

    def highlightBlock(self, text):
        # simple regexp based rules
        for rule in (self.words_rules + self.normal_rules):
            regex = rule.start
            i = text.indexOf(regex)
            while i >= 0:
                length = regex.matchedLength()
                self.setFormat(i, length, self.formats[rule.getFormat()])
                i = text.indexOf(regex, i + length)
        # caution !
        self.setCurrentBlockState(-1)

        # context based rules
        for rule in self.ctx_rules :
            startIndex = 0
            format = self.formats[rule.getFormat()]
            state = rule.state

            # this is needed is rule.start = rule.end
            # If not, indexOf will return the same values.
            delta = 0
            if rule.start == rule.stop :
                delta = rule.stop.length()

            if self.previousBlockState() != state:
                startIndex = text.indexOf(rule.start)
            else:
                delta = 0 # we are already on the same state

            while startIndex >= 0 :
                endIndex = text.indexOf(rule.stop, startIndex + delta)

                if endIndex == -1:
                    self.setCurrentBlockState(state);
                    ruleLength = text.length() - startIndex;
                else :
                    ruleLength = endIndex - startIndex + rule.stop.length()

                self.setFormat(startIndex, ruleLength, format)
                startIndex = text.indexOf(rule.start,
                                          startIndex + ruleLength)

        # comment rules
#        for rule in self.cmt_rules:
#            i = text.indexOf(rule.start)
#            if i>= 0 :
#                self.setFormat(i, text.length()-i, self.formats[rule.getFormat()])

        # c is a QString
        #

#        ## This needs to be corrected to handle more than one char
#        for rule in self.cmt_rules:
#            stack = []
#            for i, c in enumerate(text):
#                if unicode(c) in rule.not_in:
#                    if stack and stack[-1] == c:
#                        stack.pop()
#                    else:
#                        stack.append(c)
#                elif c == rule.start.pattern() and len(stack) == 0:
#                    self.setFormat(i, text.length(),
#                                   self.formats[rule.getFormat()])
#                    break

        for rule in self.cmt_rules:
            lenrule = rule.start.pattern().length()
            stack = []
            for i, _ in enumerate(text):
                c = text[i:i+lenrule]
                if unicode(c) in rule.not_in:
                    if stack and stack[-1] == c:
                        stack.pop()
                    else:
                        stack.append(c)
                elif c == rule.start.pattern() and len(stack) == 0:
                    self.setFormat(i, text.length(),
                                   self.formats[rule.getFormat()])
                    break


