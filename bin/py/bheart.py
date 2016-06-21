#!/usr/bin/env python3
import sys

HEARTS = 10
STATUS_SYM = {
    'Charging': '🗲',
    'Full': '🗲',
    'Unknown': '?'
    }

STATUS_COLOR = {
    'Charging': 'yellow',
    'Full': '#aaa',
    'Unknown': '#555'
    }

def pread(component, attr):
    try:
        return open("/sys/class/power_supply/%s/%s" % (component, attr), 'r').read().strip()
    except IOError:
        return None

def vread(end):
    maxv = float(pread(end, 'charge_full') or pread(end, 'energy_full'))
    curv = float(pread(end, 'charge_now') or pread(end, 'energy_now'))

    return curv / maxv

def sread(end):
    stat = pread(end, 'status')
    if stat == 'Unknown':
        not_charging = int(pread(end, 'power_now')) == 0
        if not_charging:
            stat = 'Full'

    return stat

def hearts(count):
    FULL = round(count * HEARTS)
    EMPTY = HEARTS - FULL

    hearts=''
    for _ in range(0, FULL):
        hearts += "♥ "
    for _ in range(0, EMPTY):
        hearts += "♡ "

    return hearts

def status(status):
    return STATUS_SYM.get(status, '')

if '--html' in sys.argv[1:]:
    stat = sread("BAT0")
    charge_color = STATUS_COLOR.get(stat, '#777')
    print(('<span color="red">%s</span>'
          + '<span color="%s">%s </span>')
          % (hearts(vread("BAT0")), charge_color, status(stat)))
else:
    print(hearts(vread("BAT0")) + status(sread("BAT0")))

