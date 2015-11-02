#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""A little blogging tool for PyK! written for my personnal use
"""

from Blog.LittleBlogger import *

from plugins import IPlugin
from editor import Editor

# PyQt specific
from PyQt4 import QtGui, QtCore

APPLIREP = os.getcwd()
PLUGINS = os.path.join(APPLIREP,'Plugins')
BLOGSDIR = os.path.join(PLUGINS,'Blog/BlogPlugin')

class blogPlugin(IPlugin):
    infos = {'name': 'blogPlugin',
            'author': 'Kibleur Christophe',
            'version': '0.0.1',
            'website':'http://kib2.free.fr/PyK/',
                }
    count = 0
    ## =======================================
    def __init__(self, parent):
        IPlugin.__init__(self,parent)


    def activate(self):

        self.editor = self.parent.getEditor()
        self.sb = self.parent.statusBar()

        ## the blog Manager
        self.blogsDir = 'Plugins/Blog/BlogPlugin/'
        self.defBlog = self.getBlogs()[0] # the default blog

        self.bm = blogManager(postdir=os.path.join(self.blogsDir,self.defBlog),parent=self)

        act = QtGui.QAction(self.parent)
        act.setText("Blog! plugin")


        # Add the plugin to the Plugins Menu once only
        #self.parent.connect(act, QtCore.SIGNAL("triggered()"), self.evalRegion)
        self.parent.menuPlugins.addAction(act)
        #self.parent.registerActionShortCut(act)

        # Now we create a new menu and a new tab
        self.addBlogMenu() # the new menu
        self.addActions() # actions in the menu
        self.addPostsTab() # the new tab


        ## reception of important signals from the main app
        QtCore.QObject.connect(self.parent, QtCore.SIGNAL("changeEditor(PyQt_PyObject)"),self.changeEditor)

        self.parent.connect(self.tableWidget_posts,
                            QtCore.SIGNAL("itemDoubleClicked(QTableWidgetItem *)")
                            ,self.viewDoubleClickedPost)

        self.parent.connect(self.parent.listWidget_projects,
                            QtCore.SIGNAL("itemDoubleClicked(QListWidgetItem *)")
                            ,self.changeBlog)

    ## ========= Menu and new Tabs management
    def addBlogMenu(self):
        """Build a new blog menu in parent's menuBar"""
        self.menuBlog = QtGui.QMenu(self.parent.menubar)
        self.menuBlog.setObjectName("menuBlog")
        self.menuBlog.setTitle('PyKBlog')
        self.parent.menubar.addMenu(self.menuBlog)

    def addActions(self):
        """Add all the possible actions to
        the BlogMenu

        - Publish this post
        - Remove a post
        """
        newPost = QtGui.QAction(self.parent)
        newPost.setText("publish")
        self.menuBlog.addAction(newPost)
        self.parent.connect(newPost,QtCore.SIGNAL("triggered()"),self.publishBlog)

        removePost = QtGui.QAction(self.parent)
        removePost.setText("transfert by FTP")
        self.menuBlog.addAction(removePost)
        self.parent.connect(removePost,QtCore.SIGNAL("triggered()"),self.transfer)

    def addPostsTab(self):
        """Add a new Tab in Projects pane
        to show all possible Posts"""
        self.tab_posts = QtGui.QWidget()
        self.tab_posts.setObjectName("tab_posts")

        self.hboxlayoutTabs = QtGui.QHBoxLayout(self.tab_posts)
        self.hboxlayoutTabs.setObjectName("hboxlayoutTabs")

        self.tableWidget_posts = QtGui.QTableWidget(self.tab_posts)
        #self.tableWidget_posts.setSelectionMode(QtGui.QAbstractItemView.MultiSelection)
        self.tableWidget_posts.setObjectName("listWidget_posts")
        self.hboxlayoutTabs.addWidget(self.tableWidget_posts)

        self.parent.tabWidget_projets.addTab(self.tableWidget_posts,QtGui.QIcon(":/Images/crystal/structure.png"),"All Posts")

        ## show them in the list
        self.refreshPostTab()

    def refreshPostTab(self):
        posts = self.bm.blogFiles
        self.tableWidget_posts.clear()
        self.tableWidget_posts.setRowCount(len(posts))
        self.tableWidget_posts.setColumnCount(1)

        for i,f in enumerate(posts) :
            newItem = QtGui.QTableWidgetItem(f,0)
            self.tableWidget_posts.setItem(i, 0, newItem)

        self.tableWidget_posts.resizeColumnsToContents()

    ## ACTIONS FROM THE MENU
    def publishBlog(self):
        self.bm.publish()

    def transfer(self):
        self.bm.transferToFtp()

    def getBlogs(self):
        blogs = [f for f in os.listdir('Plugins/Blog/BlogPlugin/') if os.path.isdir('Plugins/Blog/BlogPlugin/'+f)]
        self.parent.listWidget_projects.clear()
        self.parent.listWidget_projects.addItems(blogs)
        ## connexions
#        self.parent.connect(self.parent.listWidget_projects,
#                            QtCore.SIGNAL("itemDoubleClicked(QListWidgetItem *)")
#                            ,self.changeBlog)
        return blogs

    def changeBlog(self, it):
        self.bm.changePostDir(os.path.join(BLOGSDIR, unicode(it.text())) )
        self.refreshPostTab()
        self.parent.console.insertPlainText('Working in Blog : %s\n'%self.bm.postdir)

    def viewDoubleClickedPost(self, it):
        fileName = self.bm._in + it.text()
        self.parent.loadFile(fileName)

    def changeEditor(self, new_editor):
        """In case of parent window using multiple editors instances.
        """
        self.sb.showMessage("Editor changed",500)
        self.editor = new_editor
        self.bm.getPosts()
