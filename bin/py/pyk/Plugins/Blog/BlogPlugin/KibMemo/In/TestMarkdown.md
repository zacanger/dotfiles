[tit]Menage hivernal[/tit]
[date]2007 12 12 15 6[/date]
[tags]Python,Markup[/tags]
[markup]markdown[/markup]


PyK handles some [reStructuredText][2], or [Markdown][1]


Sourcecode like this one :

    #!python
    def addActions(self):
        """Add all the possible actions to
        the BlogMenu

        - Publish this post
        - Remove a post
        """
        newPost = QtGui.QAction(self.parent)
        newPost.setText("publish")
        self.menuBlog.addAction(newPost)
        self.parent.connect(newPost,QtCore.SIGNAL("triggered()"),self.bm.publish)

        removePost = QtGui.QAction(self.parent)
        removePost.setText("transfert by FTP")
        self.menuBlog.addAction(removePost)
        self.parent.connect(removePost,QtCore.SIGNAL("triggered()"),self.bm.transferToFtp)

[1]: http://daringfireball.net/projects/markdown        "Markdown"
[2]: http://docutils.sourceforge.net/rst.html           "reStructuredText"
