#!/usr/bin/env python

# -*- coding: utf-8 -*-

import json
import click


@click.command()
@click.version_option()
@click.option('--indent', default=2, help='Indentation.')
@click.option('-l', '--lines/--no-lines', help='One JSON object per line.')
@click.option('-s', '--sort-keys/--no-sort-keys', help='Sort keys.')
@click.argument('input', type=click.File('r'))
def jzon(indent, lines, sort_keys, input):
    separators = (',', ': ') if indent else None
    try:
        if not lines:
            d = json.load(input)
            click.echo(json.dumps(d, indent=indent, separators=separators, sort_keys=sort_keys))
        else:
            for line in input:
                d = json.loads(line)
                click.echo(json.dumps(d, indent=indent, separators=separators, sort_keys=sort_keys))
    except IOError as ex:
        if ex.errno != 32:
            raise
