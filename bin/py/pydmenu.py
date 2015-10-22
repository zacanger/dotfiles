#!/usr/bin/env python

# http://www.codercpf.be/102/pydmenu-python-yeganesh-clone/

import os
import cPickle
from subprocess import Popen, PIPE
from operator import itemgetter

__author__ = "Mathias Teugels <cpf@codercpf.be>"

SAVEFILE=os.path.expanduser('~/.pydmenu_save')
DMENU=['dmenu', '-fn', '-*-Inconsolata-*-r-normal-*-*-120-*-*-*-*-iso8859-*', '-nb', '#000000', '-nf', '#FFFFFF', '-sb', '#0066ff']
DMENU_PATH=['bash', '-c', '. ~/.bash_aliases; compgen -c']
        ## ^^ MODIFIED BY DEE NEWCUM -- include Bash aliases in the available list

def restore_saved():
    temp = {}
    if os.path.exists(SAVEFILE):
        save_file = open(SAVEFILE, 'r+')
        temp = cPickle.load(save_file)
        save_file.close()
    return temp

def save(list):
    save_file = open(SAVEFILE, 'w+')
    cPickle.dump(list, save_file)
    save_file.close()

def mySort(list):
    # Source: http://blog.modp.com/2008/09/sorting-python-dictionary-by-value-take.html
    return sorted(list.iteritems(), key=itemgetter(1),
        reverse=True)

if __name__ == '__main__':
    _total_list = restore_saved()
    first = Popen(DMENU_PATH, stdout=PIPE)
    total_list = first.communicate()[0]
    for prog in total_list.split('\n'):
        if not _total_list.has_key(prog):
            _total_list[prog] = 0

    _print = mySort(_total_list)
 
    proc = Popen(DMENU, stdin=PIPE, stdout=PIPE)
    used = proc.communicate('\n'.join([a for a,b in _print]))[0]

    if _total_list.has_key(used):
        _total_list[used] += 1
    else:
        _total_list[used] = 1
    save(_total_list)

    print(used)
