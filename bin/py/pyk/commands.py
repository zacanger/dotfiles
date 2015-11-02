import os
import xml.etree.cElementTree as ET
from PyQt4 import QtGui, QtCore

APPLIREP = os.getcwd()
COMMANDS = os.path.join(APPLIREP,'Commands')
SCRIPTS = os.path.join(APPLIREP,'Scripts')

exitStatusDic = {   0: 'NormalExit',
                    1: 'CrashExit',
                }

class editCommands(object):
    """
    args : arguments you pass to mainscript
    ---------------------------------------
    %home     : your home directory
    %baseName :
    %realName :

    wd : working directory
    ----------------------
    %appDir   : application's directory
    %sciptDir : the script directory
    """
    def __init__(self, parent, context, name, key, cmd, args, wd=""):
        self.parent = parent # the parent window
        self.ed = self.parent.getEditor()
        self.name = name # ie 'LaTeX compile'
        self.context = context.split() # ie .py, .tex
        self.cmd = QtCore.QString(cmd) # name of the command to execute
        self.args = args # args of the command
        self.key = key # key shortcut

        if wd == "":
            self.working_dir = self.ed.get_fileDir()
        else:
            wd = wd.replace("%appDir",APPLIREP)
            wd = wd.replace("%sciptsDir",SCRIPTS)
            self.working_dir = wd


    def getAction(self):
        self.act = QtGui.QAction(self.parent)
        self.act.setIcon(QtGui.QIcon(":/Images/crystal/tab.png"))
        self.act.setText(self.name)
        self.act.setShortcut(self.key)
        self.parent.connect(self.act,QtCore.SIGNAL("triggered(bool)"),self.execute)
        return self.act

    def execute(self):
        ## Output in the console window
        if unicode(self.ed.get_fileExtension()) not in self.context :
            self.parent.console.setPlainText(u"The file extension does not match the context %s"%self.context)
            return
        self.parent.console.clear()


        ## creates a process
        self.proc = QtCore.QProcess(self.parent)
        self.proc.setWorkingDirectory(self.working_dir)

        #self.proc.setWorkingDirectory(self.ed.get_fileDir())
        arglist = QtCore.QStringList()

        if self.args :
            for el in self.args.split() :
                el = QtCore.QString(el)
                el.replace(QtCore.QRegExp("%home"),QtCore.QDir.homePath())
                if el.startsWith("%baseName"):
                    el.replace(0,9,self.ed.get_fileBaseName())
                elif el.startsWith("%realName"):
                    el.replace(0,9,self.ed.get_fileDir()+r"/"+self.ed.get_fileBaseName())
                arglist.append(el)


        beautify_arglist = ' '.join([unicode(el) for el in list(arglist)])

        self.parent.console.insertPlainText(u'Working in directory: %s\n'%self.working_dir)
        self.parent.console.insertPlainText(u'Executing the script: %s\n'%self.cmd)
        self.parent.console.insertPlainText(u'With the arguments: %s\n'%beautify_arglist)
        #self.parent.console.insertPlainText(u'Executing %s %s'%(beautify_arglist,self.ed.get_realFileName()))

        self.parent.connect(self.proc,QtCore.SIGNAL("finished(int,QProcess::ExitStatus)"),self.asFinished)
        self.parent.connect(self.proc,QtCore.SIGNAL("readyReadStandardOutput()"),self.showOut)



        self.proc.start(self.cmd, arglist)
        self.proc.waitForFinished(2000)

    def asFinished(self, n,k):
        self.parent.console.insertPlainText(u"-"*50+u"\n")
        self.parent.console.insertPlainText(u"exitCode %s and exitStatus %s"%(n,exitStatusDic[k]))
        self.parent.console.insertPlainText(u"\nProcess state = %s"%self.proc.state())

    def asStarted(self):
        self.parent.console.insertPlainText(u"-"*50+u"\n")
        self.parent.console.insertPlainText(u"Process started...\n")

    def error(self):
        self.proc.kill()

    def getError(self, err):
        print 'error',exitStatusDic[self.proc.exitStatus()],self.proc.state()
        self.proc.terminate()

    def showOut(self):
        while self.proc.canReadLine() :
            someoutput = QtCore.QString(self.proc.readLine())
            if not someoutput.isEmpty():
                if someoutput.startsWith('!') :
                    self.parent.console.insertPlainText(u"-"*50+u"\n")
                    self.parent.console.insertPlainText(u"LaTeX error !")
                    self.error()
                    break
                else:
                    self.parent.console.insertPlainText(someoutput)
                    #self.parent.console.insertPlainText(unicode(self.proc.state()))


def readCommandsFromXML(parent=None,filename=r'Commands.xml'):
    file = COMMANDS+"/" + filename
    #parent.statusBar().showMessage(u'Parsing Commands file: %s'%file)
    doc = ET.parse(file)
    entries = doc.findall("command/cmd")

    cmds = []

    for entry in entries:
        ## catch the arguments of the command
        try:
            args = entry.attrib["args"]
        except:
            args = None


        ## create a command by giving
        ## parent, context, name, key, cmd, args
        cmd = editCommands( parent,
                            entry.attrib["context"],
                            entry.attrib["name"],
                            entry.attrib["key"],
                            entry.text,
                            args,
                            entry.attrib["wd"]
                            )
        cmds.append( cmd )

    #print "All commands have been read correctly !\n"

    return cmds

#readCommandsFromXML(r'Commands.xml')
