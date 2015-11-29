# Copyright 2012-2015 Mitchell mitchell.att.foicica.com. See LICENSE.

# This script uses Python to generate tags and apidoc for the Textadept Python
# module. To regenerate, modify the list of modules as necessary and then run
# `python gen_tagsapi.py`. Sub-modules are included automatically.

modules = [
  # String Services
  'string',
  're',
  #'struct',
  #'difflib',
  #'StringIO',
  #'cStringIO',
  'textwrap',
  #'codecs',
  #'unicodedata',
  #'stringprep',
  #'fpformat',

  # Data Types
  'datetime',
  'calendar',
  #'collections',
  #'heapq',
  #'bisect',
  #'array',
  #'sets',
  #'sched',
  #'mutex',
  #'Queue',
  #'weakref',
  #'UserDict',
  #'UserList',
  #'UserString',
  'types',
  #'new',
  #'copy',
  #'pprint',
  #'repr',

  # Numeric and Mathematical Modules
  #'numbers',
  'math',
  #'cmath',
  'decimal',
  #'fractions',
  'random',
  #'itertools',
  #'functools',
  #'operator',

  # File and Directory Access
  # Note: os.path is loaded from 'os' later
  #'fileinput',
  #'stat',
  #'statvfs',
  #'filecmp',
  'tempfile',
  #'glob',
  #'fnmatch',
  #'linecache',
  #'shutil',
  #'dircache',
  #'macpath',

  # Data Persistence
  #'pickle',
  #'cPickle',
  #'copy_reg',
  #'shelve',
  #'marshal',
  #'anydbm',
  #'whichdb',
  #'dbm',
  #'gdbm',
  #'dbhash',
  #'bsddb',
  #'dumbdbm',
  #'sqlite3',

  # Data Compression and Archiving
  #'zlib',
  #'gzip',
  #'bz2',
  #'zipfile',
  #'tarfile',

  # File Formats
  #'csv',
  #'ConfigParser',
  #'robotparser',
  #'netrc',
  #'xdrlib',
  #'plistlib',

  # Cryptographic Services
  #'hashlib',
  #'hmac',
  #'md5',
  #'sha',

  # Generic Operating System Services
  'os',
  'io',
  'time',
  'argparse',
  #'optparse',
  #'getopt',
  #'logging',
  #'getpass',
  #'curses',
  #'platform',
  #'errno',
  #'ctypes',

  # Optional Operating System Services
  #'select',
  #'threading',
  #'thread',
  #'dummy_threading',
  #'dummy_thread',
  #'multiprocessing',
  #'mmap',
  #'readline',
  #'rlcompleter',

  # Interprocess Communication and Networking
  #'subprocess',
  'socket',
  #'ssl',
  #'signal',
  #'popen2',
  #'asyncore',
  #'asynchat',

  # Internet Data Handling
  #'email',
  #'json',
  #'mailcap',
  #'mailbox',
  #'mhlib',
  #'mimetools',
  #'mimetypes',
  #'MimeWriter',
  #'mimify',
  #'multifile',
  #'rfc822',
  #'base64',
  #'binhex',
  #'binascii',
  #'quopri',
  #'uu',

  # Structured Markup Processing Tools
  #'HTMLParser',
  #'sgmllib',
  #'htmllib',
  #'htmlentitydefs',
  #'xml',

  # Internet Protocols and Support
  #'webbrowser',
  #'cgi',
  #'cgitb',
  #'wsgiref',
  #'urllib',
  #'urllib2',
  #'httplib',
  #'ftplib',
  #'poplib',
  #'imaplib',
  #'nntplib',
  #'smtplib',
  #'smtpd',
  #'telnetlib',
  #'uuid',
  #'urlparse',
  #'SocketServer',
  #'BaseHTTPServer',
  #'SimpleHTTPServer',
  #'CGIHTTPServer',
  #'cookielib',
  #'Cookie',
  #'xmlrpclib',
  #'DocXMLRPCServer',

  # Multimedia Services
  #'audioop',
  #'imageop',
  #'aifc',
  #'sunau',
  #'wave',
  #'chunk',
  #'colorsys',
  #'imghdr',
  #'sndhdr',
  #'ossaudiodev',

  # Internationalization
  #'gettext',
  #'locale',

  # Program Frameworks
  #'cmd',
  #'shlex',

  # Graphical User Interfaces with Tk
  #'Tkinter',
  #'ttk',
  #'Tix',
  #'ScrolledText',
  #'turtle',

  # Development Tools
  #'pydoc',
  #'doctest',
  #'unittest',
  #'test',

  # Debugging and Profiling
  #'bdb',
  #'pdb',
  #'hotshot',
  #'timeit',
  #'trance',

  # Python Runtime Services
  'sys',
  #'sysconfig',
  #'__builtin__',
  #'future_builtins',
  #'__main__',
  #'warnings',
  #'contextlib',
  #'abc',
  #'atexit',
  #'traceback',
  #'__future__',
  #'gc',
  #'inspect',
  #'site',
  #'user',
  #'fpectl',
  #'distutils',

  # Custom Python Interpreters
  #'code',
  #'codeop',

  # Restricted Execution
  #'rexec',
  #'Bastion',

  # Importing Modules
  #'imp',
  #'importlib',
  #'imputil',
  #'zipimport',
  #'pkgutil',
  #'modulefinder',
  #'runpy',

  # Python Language Services
  #'parser',
  #'ast',
  #'symtable',
  #'symbol',
  #'token',
  #'keyword',
  #'tokenize',
  #'tabnanny',
  #'pyclbr',
  #'py_compile',
  #'compileall',
  #'dis',
  #'pickletools',

  # Miscellaneous Services
  #'formatter',

  # MS Windows Specific Services
  #'msilib',
  #'msvcrt',
  #'_winreg',
  #'winsound',

  # Unix Specific Services
  #'posix',
  #'pwd',
  #'spwd',
  #'grp',
  #'crypt',
  #'dl',
  #'termios',
  #'tty',
  #'pty',
  #'fcntl',
  #'pipes',
  #'posixfile',
  #'resource',
  #'nis',
  #'syslog',
  #'commands',

  # Mac OSX Specific Services
  #'ic',
  #'MacOS',
  #'macostools',
  #'findertools',
  #'EasyDialogs',
  #'FrameWork',
  #'autoGIL',
  #'ColorPicker',

  # MacPython OSA Modules
  #'gensuitemodule',
  #'aetools',
  #'aepack',
  #'aetypes',
  #'MiniAEFrame',

  # SGI IRIX Specific Services
  #'al',
  #'AL',
  #'cd',
  #'fl',
  #'FL',
  #'flp',
  #'fm',
  #'gl',
  #'DEVICE',
  #'GL',
  #'imgfile',
  #'jpeg',

  # SunOS Specific Services
  #'sunaudiodev',
  #'SUNAUDIODEV',
]

import types
import re

TAG = '%s\t_\t0;"\t%c\t%s\n'

def format_doc(doc):
  """
  Formats the given docstring for API documentation.
  """

  try:
    return doc.rstrip().replace('\n', '\\n') if doc else ''
  except:
    return ''

def tag_object(obj, name):
  """
  Loop through all attrs in the given, named object, tagging and documenting
  sub-modules, classes, functions, and class members.
  If no name for the object is given, `obj.__name__` is used.
  """
  name = name if name != None else obj.__name__
  ext_fields = 'class:%s' % name if name else ''

  for attr in dir(obj):
    # Ignore private attrs.
    if attr.startswith('_') and not attr.startswith('__'):
      continue

    mod_attr = getattr(obj, attr)
    attr_type = type(mod_attr)
    full_name = name + '.' + attr if name else attr
    if attr_type is types.ModuleType:
      # Tag and document the sub-module.
      tag_module(full_name)
    elif attr_type is types.ClassType:
      # Tag and document the class.
      tags.write(TAG % (attr, 'c', ext_fields))
      api.write('%s %s\\n%s\n' %
                (attr, full_name, format_doc(mod_attr.__doc__)))
      tag_object(mod_attr, None)
    elif callable(mod_attr):
      # Tag and document the function.
      # If the documentation contains a function signature, use it. Otherwise
      # it is assumed to be empty.
      tags.write(TAG % (attr, 'f', ext_fields))
      try:
        i = (mod_attr.__doc__ or '').find(attr + '(')
      except:
        i = -1
      if i >= 0:
        api.write('%s %s%s\n' %
                  (attr, full_name,
                   format_doc(mod_attr.__doc__[i + len(attr):])))
      else:
        api.write('%s %s()\\n%s\n' %
                  (attr, full_name, format_doc(mod_attr.__doc__)))
    else:
      # Tag and document the class member.
      tags.write(TAG % (attr, 'm', ext_fields))
      api.write('%s %s [%s]\n' %
                (attr, full_name, re.search("'([^']+)'",
                                            str(attr_type)).group(1)))

def tag_module(module):
  """
  Tags and writes apidoc for the given string module name.
  Also tags and documents classes, functions, and class members in the module.
  Any submodules with subsequent classes, functions, and class memebrs are also
  imported, tagged, and documented.
  """

  try:
    # Import the module.
    mod = __import__(module)
    print('imported ' + module)
    for submodule in module.split('.')[1:]:
      mod = getattr(mod, submodule)

    # If successful, tag and document it with a super-module if necessary.
    i = module.rfind('.')
    ext_fields = 'class:%s' % module[:i] if i >= 0 else ''
    tags.write(TAG % (module[i + 1:], 'M', ext_fields))
    api.write('%s %s\\n%s\n' %
              (module[i + 1:], module, format_doc(mod.__doc__)))

    tag_object(mod, module)
  except ImportError, e:
    pass

# Raw objects to tag and document.
objects = [
  '', (), [], {}, 0, 0.0, file('init.lua') #, TODO: buffer(''), tag_module
]

tags = open('tags', 'w')
api = open('api', 'w')
for module in modules:
  tag_module(module)
for obj in objects:
  tag_object(obj, re.search("'([^']+)'", str(type(obj))).group(1))
tag_object(__builtins__, '')
tags.close()
api.close()
