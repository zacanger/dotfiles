import re
#try:
#    import psyco
#    psyco.log()
#    psyco.profile(0.2)
#except:
#    pass

"""
A snippet engine for QTextEdit.
"""

# Copyright (C) 2007 Christophe Kibleur <kib2@free.fr>
#
# This file is part of reSTinPeace (http://kib2.alwaysdata.net).
#
# reSTinPeace is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# reSTinPeace is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
tex = "documentclass[${1:options}]{${2:class}}"
test =  "un ${1:Youpi} vaut mieux que ${1/Un/Trala/.upper()}"
toto = "un ${1:LIP} de ${2:kib} pour ${3:truc} et $1 et ${4:fin}\n\t$3 pour ${5:machin}"
cf = "${1/.*/len(r)*'='}\n${1:Titre}\n${1/.*/len(r)*'='}\n$0"
gg = "- (${1:id})${2:foo}\n{ return $2;}\n- (void)set${2/./p.sub('.',r)}:($1)aValue\n{\n\t [$2 autorelease];\n\t$2 = [aValue retain];\n}"

class Snippet(object):

    def __init__(self, template):
        ## If there's no endmarker, we put one at the end
        if template.find('$0') == -1:
            template += '$0'

        ## Regular expressions used
        self.splitter = re.compile('(\${.*?}|\$\d+)')
        self.master = re.compile('(\${(\d+):(.*?)})')
        self.trafo = re.compile(r'(\${(\d+)/(.*?)/(.*?)})')
        self.slave = re.compile('(\$(\d+))')
        self.endfield = re.compile('\$[0]')

        self.template = template
        self.decomposed = self.decomposeSnippet()
        self.fields = []
        self.getFields()
        self.ids = [f.id for f in self.fields]
        self.sortie = self.expand()

        self.current_field = None
        self.start = 0
        self.long = 0

    def decomposeSnippet(self):
        return self.splitter.split(self.template)


    #def __str__(self):
    #    return self.template

    def expanded(self):
        # we need to update the fields start pos
        # if there are ones before the parent field
        for f in self.fields :
            f.start = self.getFieldPos(f)
        return "".join(self.expand())

    def getFields(self):
        # get the masters
        for ind,el in enumerate(self.decomposed):
            k=self.master.match(el)
            if k:
                self.fields.append(PlaceHolderField(k, id=ind,parent=self))

        # get the slaves
        for ind,el in enumerate(self.decomposed):
            sm=self.slave.match(el)
            if sm:
                indice = int(sm.group(2))
                if indice != 0:
                    # we must find his master
                    for m in self.fields :
                        if int(m.num) == indice :
                            m.slaves.append(ind)

        # trafo markers
        ## (\${(\d+)/(.*?)/(.*?)/(.*?)})
        for ind,el in enumerate(self.decomposed):
            t=self.trafo.match(el)
            if t:
                indice = int(t.group(2))
                if indice != 0:
                    for m in self.fields :
                        if int(m.num) == indice :
                            papa = self.getFieldFromId(indice)
                            m.trafos.append(TrafoField(t, id=ind, father=papa))

        # end
        for ind,el in enumerate(self.decomposed):
            ed=self.endfield.match(el)
            if ed:
                self.fields.append(EndField(ed, id=ind,parent=self))
                return

    def getFieldFromString(self, thestring):
        for f in self.fields :
            if "$0" == thestring :
                return ""
            if f.code == thestring :
                return f.content

            for t in f.trafos :
                if t.code == thestring :
                    return t.getContents()

            for s in f.slaves:
                if "$"+ f.num == thestring :
                    return f.content
        return thestring

    def getFieldFromId(self, theid):
        for f in self.fields :
            if int(f.num) == theid :
                return f
        print "This field does not seems to have any parent"
        
    def getFieldBefore(self, thefield):
        g = self.fields[0]
        for f in self.fields :
            if f == thefield :
                return g
            g = f

    def expand(self):
        sortie = []
        for somestr in self.decomposed:
            il = self.getFieldFromString(somestr)
            sortie.append(il)
        return sortie

    def getFieldPos(self, field):
        pos = 0
        expandedlist = self.expand()
        for i in range(int(field.id)):
            pos += len(expandedlist[i])
        return pos

    def fieldIter(self):
        for field in self.fields :
            yield field
            
    def __str__(self):
        k = []
        for f in self.fields:
            k.append(f.code)
        return "--".join(k)
        
class Field(object):
    """This class is never used directly.
    It has to be derived.
    """
    def __init__(self, regexp, parent=None, id=0):
        self.regexp= regexp
        self.parent = parent
        self.id = str(id) # indice dans la liste
        self.start = 0
        self.long = 0
        self.trafos = []
        self.slaves=[]
        self.code = ''

    def get_content(self):
        return self.content

    def set_content(self,value):
        self.content = value
        for f in self.trafos :
            f.getContents()

    def getLengh(self):
        return len(self.content)

    def hasSlaves(self):
        if len(self.slaves) > 0:
            return True
            
    def __str__(self):
        return self.code       
    

class PlaceHolderField(Field):
    def __init__(self, regexp, parent=None, id=0):
        Field.__init__(self, regexp, parent, id)

        self.code = self.regexp.group(0)
        self.num = self.regexp.group(2) # ${num:...}
        self.content = self.regexp.group(3)
        self.isEnd = False

class TrafoField(Field):
    ## ${num/pattern/replacement/options}
    ## num          : le groupe a transformer dans le field parent
    ## pattern      : le motif a chercher
    ## replacement  : par quoi
    def __init__(self, regexp, parent=None, id=0, father=None):
        Field.__init__(self, regexp, parent, id)
        self.father = father
        #print "Father code=",self.father.code
        self.code = self.regexp.group(0)
        self.num = self.regexp.group(2) # ${num:...}
        self.pattern = self.regexp.group(3)
        self.replacement = self.regexp.group(4)
        #self.options = self.regexp.group(5)
        #print "options=",self.options
        self.content = self.getContents()
        self.isEnd = False

    def replacer(self,match):
        """On fourni un objet matche et on le transforme selon

        In ${2/./p.sub('.',r)} we'll have (all string types):

        @ g  =2
        @ r  =.
        @ rp = p.sub('.',r)
        """

        g = int(self.num)
        r = self.pattern
        rp = self.replacement

        # the whole expression
        expr = match.group()
        patt = re.compile(r)

        s=eval(rp, {'EXP': expr, 'PAT': patt})

        return s

    def getContents(self):
        # ${num/pattern/replacement/options}
        # sub(replacement, string[, count = 0])
        patt = re.compile(self.pattern)
        avanteval = patt.sub(self.replacer,self.father.content)

        return unicode(avanteval)

class EndField(Field):
    def __init__(self, regexp, parent=None, id=0):
        Field.__init__(self, regexp, parent, id)

        self.code = '$0'
        self.num = '0'
        self.content =''
        self.isEnd = True


## ---------------------------
## Only for testing...
## ---------------------------
if __name__ == "__main__":
    # Essaye de trouver les champs

    s = Snippet(tex)
    for f in s.fields:
        print f, s.getFieldBefore(f)
    print "s=",s
    print "Expanded=\n",s.expanded()


