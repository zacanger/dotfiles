==================
Welcome to PyEdit!
==================

.. contents::

PyEdit is a new editor, allowing some forgotten langages to be edited, 
but also some common ones.

It has nice features and is highly extensible via plugins and commands.

Requirements
============

I've actually not tested other versions, so please report me bugs.

- Python > 2.5.1 ;
- PyQt 4.3.1 ;
- DejaVu Sans Mono fonts [optionnal, but very recommended];

Features
========

With each of these file types, it is possible to compile them, 
view the output in different formats. In fact, you just have to load
the file and follow the Commands menu/shortcuts to view all possible actions.
Actions are configurable via an XML file format. 

For example, this site is just a file and I just ask PyEdit to produce 
HTML output from it via the F1 key. I can then view the output in 
Firefox via F2.

Here's a non limited list of supported langages :

- `reStructuredText <http://docutils.sourceforge.net/rst.html>`_ ;

- `Python <http://www.python.org/>`_ ;

- `Asymptote <http://asymptote.sourceforge.net/>`_ ;

- `LaTeX <http://www.latex-project.org/>`_ ;

- `MetaPost <http://cm.bell-labs.com/who/hobby/MetaPost.html>`_ ;

- `Lout <http://www.qtrac.eu/lout.html>`_ ;

- Other formats needs support at the moment;

Here's a table of supported langages :

+------------------+-------------------------+
| Langage          | Highlight Level (/5)    |
+==================+=========================+
| reStructuredText | 2                       |
+------------------+-------------------------+
| Python           | 3                       |
+------------------+-------------------------+
| Asymptote        | 4                       |
+------------------+-------------------------+
| LaTeX            | 3                       |
+------------------+-------------------------+
| MetaPost         | 2                       |
+------------------+-------------------------+
| Lout             | 2                       |
+------------------+-------------------------+
| XML              | 2                       |
+------------------+-------------------------+
| CSS              | 2                       |
+------------------+-------------------------+
| C/C++            | 3                       |
+------------------+-------------------------+

Plugins
=======

PyEdit supports a limited plugins architecture. At the time writing this page,
here are the implemented plugins : 

- TextMate-like snippets and a `snippets video <http://kib2.free.fr/PyEdit/snippets.ogg>`_ with the new ``PyK`` engine not yet release;
- Multicursors editing and a `multicursors video <http://kib2.free.fr/PyEdit/pyedit.ogg>`_ ;
- SmartIndent;

In the Scheme directory you'll find XML files. Each one contains :

- the grammar and syntax colorisation (you can add your own keywords);
- the snippets definitions for a given langage;

You can edit them to add/sub whatever you want.

Commands
========

From PyEdit, you can also define your own commands. 
They're inside the commands directory: again an XML file.
Look at the given samples to give you an idea about what's going on, but 
we'll study here a first one.

.. sourcecode:: xml

    <cmd context=".tex" key="F1" args="%baseName.tex" name="pdfLaTeX" icon="" wd="">pdflatex</cmd>    

Here, context means file extension, key is the keyboard shortcut to launch the
given command, args are the arguments to pass to the major command. I'm using
'%baseName' to indicate the file name without its extension. name and icon are 
just the name and the icon of the command appearing in the Commands menu.
icon is not implemented yet. wd is an option to set the work directory; as it
is here left blank, we're working in the application's directory.
pdflatex is just the major command.  

Limitations
===========

- Syntax Highlighting maybe slow with large documents when loading the file;

Performances
============

PyEdit is pretty slow, that's a fact because I choose not to use the
Scintilla control (I don't like the API behind it). 
So it needs to do all the drawings by itself.
If you need more performance, toogle-off some options in the     
View menu, particulary :

- the line numbers margin ;

- the white spaces/tabs;  

Screenshots
===========

Editing an Asymptote file :    

.. image:: http://farm3.static.flickr.com/2214/2061342659_58619ffa5f.jpg?v=0
    :scale: 100
    :alt: shot1
    :align: center
    :target: http://farm3.static.flickr.com/2214/2061342659_28d9e7ddff_o.png

Editing a LaTeX file :

.. image:: http://farm3.static.flickr.com/2217/2062130832_d834dba555.jpg?v=0
    :scale: 100
    :alt: shot2
    :align: center
    :target: http://farm3.static.flickr.com/2217/2062130832_729604d38d_o.png    

Editing a reStructuredText file:    

.. image:: http://farm3.static.flickr.com/2261/2062130456_dd3c15f764.jpg?v=0
    :scale: 100
    :alt: nom
    :align: center
    :target: http://farm3.static.flickr.com/2261/2062130456_88cf18b7c8_o.png

Editing a Python file :    

.. image:: http://farm3.static.flickr.com/2409/2061342291_e7d883eb2d.jpg?v=0
    :scale: 100
    :alt: nom
    :align: center
    :target: http://farm3.static.flickr.com/2409/2061342291_4576f952cc_o.png    

Editing a Lout file :    

.. image:: http://farm3.static.flickr.com/2216/2062065859_d8e1aecf18.jpg?v=0
    :scale: 100
    :alt: nom
    :align: center
    :target: http://farm3.static.flickr.com/2216/2062065859_c8c0aa453f_o.png

The future with ``PyK`` :

.. image:: http://farm3.static.flickr.com/2297/2074690298_90986ddc95.jpg?v=0
    :scale: 100
    :alt: nom
    :align: center
    :target: http://farm3.static.flickr.com/2297/2074690298_90986ddc95_b.jpg

News
====

PyEdit will become ``Pyk`` and will now be hosted with 
`LaunchPad <https://launchpad.net/>`_  . In fact, I'm just starting to
know how to use it correctly :)

- I just tested a new command named ``Send by FTP`` : it seems to work quite 
  fine as I'm editing this page in reSt format and just have to hit my F1 key
  to transform it to HTML, then F6 to send it by FTP.

- Made a ``Tables`` plugins : very usefull for reStructuredText docs !

Download
========

Last update on : Nov 27, 2007

.. warning::
   The download is disable untill the next new version comes out.
   I'm currently rewritting it from scratch, I'll use some Design 
   Patterns to help me managing plugins.


If you're under a Linux system, maybe you'll find it better to have a bash
file for launching PyEdit. I'm made my own one, you only have to modify line 3
according to the directory where 'main.py' resides.

Launching it otherwise with : ``python main.py`` or ``python main.py myfile``.

Changelog
=========

- v0.1.4: Corrected the bugs in the todo list, added Windows CP1252 encoding. Now that I've read Mark Summerfield chapter 9, I'm convinced I had complicated things a little bit and I need to review some parts of my code.

- v0.1.3: All plugins are applied correctly to the current editor now; Added a bom checkBox for UTF-8 encoded files.

- v0.1.2: Added some more plugins, one langage (MetaPost) corrected some bugs and added encoding support.

Todo
====
    
*Some feebacks by Mark Summerfield :*     

- Add some accelerators to the menu for keyboard-only users; **-- DONE--** 
- The tabWidget seems broken when there's no more tabs. **-- DONE--** 
- The about dialog 'info' tab is not lay out; **-- DONE--** 
- The Project first tab is named 'projet' (that's the name in French...) instead of 'projects'; **-- DONE--** 

All these points should be fixed soon in the next version.

*The others are just bad things I saw while editing, and 
will be fixed when I find the time for:* 

- The shortcuts window does not adapt to the column sizes yet;
- Add more encoding support;
- Preserve the console output according to the current editor;
- Console output needs more work to know if a process has failed;
- Review the syntax highlighter to handle difficult cases like comments in Python inside strings or vice-versa; 
- The plugin implementation needs to be better implemented.

Thanks
======

- Mark Summerfield for his help, patience and kindness. His last book `"Rapid GUI Programming with Python and Qt" <http://www.qtrac.eu/pyqtbook.html>`_ is just a must have, really.

- `Armin Ronacher <http://lucumr.pocoo.org>`_ the different articles he wrotes on Python. He gave me the basic idea for plugins support with this `one <http://lucumr.pocoo.org/blogarchive/python-plugin-system>`_. Moreover, he's one of the `Pygments <http://pygments.org/>`_ developper and I use it myself a lot !

Contact
=======

For bugs and suggestions : kib2 at free.fr.
Thanks in advance.