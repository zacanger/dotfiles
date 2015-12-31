#! /usr/bin/env python

from dateutil import parser
from datetime import datetime
from subprocess import Popen, PIPE
from StringIO import StringIO
from ConfigParser import SafeConfigParser

import argparse
import os
import pprint
import sys

def load_name_from_git():
    """
    Load the local user's local git name.

    """

    p = Popen('git config user.name', shell=True, stdout=PIPE)
    (result, _) = p.communicate()
    return result.strip()

def main():
    """
    Main application flow.

    """
    arg_parser = argparse.ArgumentParser(description='Gitlog. Get days worked from Git history..\n')
    arg_parser.add_argument('-r','--repos', nargs='+', help='<Required> List of repos', required=True)
    arg_parser.add_argument('-n', '--name', type=str, default='',
                        help='Name of the author to use. Defaults to _git config user.name_.')

    args = arg_parser.parse_args()
    vargs = vars(args)

    if not any(vargs.values()):
        arg_parser.error('Please list repos to log!')

    if vargs['name']:
        name = vargs['name'].replace(';', '').replace('|', '').replace('&', '').replace('>', '').replace('<', '')
    else:
        name = load_name_from_git()

    lines = ''
    command = 'git log --format=format:"%ad %aN %s (%h)" --author="' + name + ' " --date=local'

    days = {}
    for repo in vargs['repos']:
        try:
            p = Popen(command, cwd=repo, shell=True, stdout=PIPE)
            (log, _) = p.communicate()
            lines = lines + log + "\n"
        except Exception, e:
            continue

    for line in lines.split('\n'):
        if name not in line:
            continue
        else:
            date_s, task_s = line.split(name) #[0].strip()
            day_s = ' '.join(date_s.split(':')[0].split(' ')[:-1])
            dt = parser.parse(day_s.strip())
            if days.has_key(dt):
                days[dt].append(task_s.strip())
            else:
                days[dt] = [task_s]

    for day in sorted(days.keys()):
        print(day.strftime("%A, %B %d, %Y"))
        for stamp in days[day]:
            print('\t - ' + stamp)
   
####################################################################
# Main
####################################################################

if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception, e:
        print(e)