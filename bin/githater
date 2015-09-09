#!/usr/bin/env python
import sys
import operator
import pprint
from stemmer import PorterStemmer

db = {
  'ls-time': {
    'description': "Show the last time a file was updated in the current git repo directory",
    'data': 'for a in $(ls);do git log --pretty=format:"%ad%x09$a" -1 -- "$a";done',
    'safe': True
  },
  'tag-time': {
    'description': "Show the timestamps of all the annotated tags and sort by that",
    'data': "git for-each-ref --format='%(committerdate:iso8601)%(taggerdate:iso8601) %(refname:short)' refs/tags | sort -n",
    'safe': True
  },
  'new-repo': {
    'description': 'Create a new repository and set the permissions right',
    'data': '( r=<repo-name>.git g=<group-name>; mkdir $r && chgrp $g $r && chmod g+s $r && git init --shared --bare $r )',
    'safe': False
  },
  'new-branch-push': {
    'data': 'Create a branch. Use it. Push.'
  },
  'undo-commit': {
    'data': 'git reset --soft HEAD^ will undo a local commit without undoing your code.'
  },
  'delete-branch': {
    'data': 'git push remote :branch deletes branch on remote.'
  },
  'fast-clone': {
    'description': 'Only clone what is necessary to get going',
    'data': 'git clone --depth 1'
  },
  'browser': {
    'data': 'git instaweb -d daemon --start'
  },
  'push-all': {
    'data': 'git push --tags'
  }
}


# The words on the left get converted to the words on the right
synonymMap = {
 'dir' : 'ls',
 'show' : 'ls',
 'creat': 'new',
 'init': 'new',
 'web': 'browser',
 'browse': 'browser',
 'quickli': 'fast',
 'quick': 'fast',
 'when': 'time',
 'everything': 'all'
}

weightMap = {
  'new': {
    'new-repo': 1
  },
  'fast': {
    'fast-clone': 1
  },
  'browser': {
    'browser' : 1
  },
  'file' : {
    'ls-time': 1
  },
  'ls' : {
    'ls-time': 1,
    'tag-time': 1
  },
  'refspec': {
    'new-branch-push': 2
  }
}

computed = {}
stemmer = PorterStemmer()
for word in sys.argv[1:]:
  word = stemmer.stem(word.lower())
  print word
  if word in synonymMap:
    word = synonymMap[word]

  if word in weightMap:
    for key, value in weightMap[word].iteritems():
      if key in computed:
        computed[key] += value
      else:
        computed[key] = value

sorted_computed = sorted(computed.iteritems(), key=operator.itemgetter(1))

sorted_computed.reverse()

pp = pprint.PrettyPrinter(indent=4)
for (key, value) in sorted_computed:
  pp.pprint(db[key])
