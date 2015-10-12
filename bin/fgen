#! /usr/bin/env python2
##
## fgen.py for fgen
## by lenormf
##

import os
import sys
import string
import logging
import argparse

class Defaults:
    VERSION = (0, 1)
    DIR_TEMPLATES = os.path.join(os.getenv("HOME"), "templates")
    SEPARATOR_KEY_VALUE = ":"

## Wrapper of the builtin "open()" function that catches all possible exceptions
## Returns a file descriptor on success, None otherwise
def open_file(path, mode):
    try:
        return open(path, mode)
    except Exception as e:
        logging.debug("An error occurred while opening file \"{0}\": {1}".format(path, e))
        return None

## Create a new file at `new_file` that will contain the rendered template contained in `template_path` with the given `context`
def render_template(template_path, new_file, context):
    fin = open_file(template_path, "r")
    if not fin:
        logging.critical("Unable to open file \"{0}\"".format(template_path))
        return False

    if new_file != "-":
        fout = open_file(new_file, "w")
        if not fout:
            logging.critical("Unable to open file \"{0}\"".format(new_file))
            return False
    else:
        fout = sys.stdout

    for line in fin:
        tmpl = string.Template(line)
        line = tmpl.safe_substitute(**context)

        fout.write(line)

    fin.close()
    if new_file != "-":
        fout.close()

    return True

## Get the full path of the template refered to as `name` in `templates_dir`
## This function will ignore file extensions if possible
def get_template_path(templates_dir, name):
    files_list = [ f for f in os.listdir(templates_dir) if os.path.isfile(os.path.join(templates_dir, f)) ]
    for filename in files_list:
        prefix = None
        ext = filename.rsplit(".", 1)
        if len(ext) > 1:
            prefix = ext[0]

        if name == filename or name == prefix:
            return os.path.join(templates_dir, filename)

    return None

## Print the list of all the templates in `templates_dir` on the standard output
def list_template_names(templates_dir):
    files_list = [ f for f in os.listdir(templates_dir) if os.path.isfile(os.path.join(templates_dir, f)) ]
    for filename in files_list:
        print filename

def get_args(av):
    parser = argparse.ArgumentParser(description="A minimalistic file generator that uses python templates with the curly brace syntax")

    parser.add_argument("-d", "--debug", action="store_true", help="Display debug information")
    parser.add_argument("-v", "--verbose", action="store_true", help="Display more information")
    parser.add_argument("-f", "--filename", help="Name of the file that will be generated (default: name of the template in the current working directory)")
    parser.add_argument("-t", "--templates", default=Defaults.DIR_TEMPLATES, help="Path to the directory that contains all the templates")
    parser.add_argument("-s", "--separator", default=Defaults.SEPARATOR_KEY_VALUE, help="Separator to trim between the key and the value of the context parameters")
    parser.add_argument("-l", "--list", action="store_true", help="List all the templates available from the templates directory")
    parser.add_argument("template", nargs=1, help="Name of the template to use (no extension needed)")
    parser.add_argument("vars", nargs="*", metavar="variable{0}value".format(Defaults.SEPARATOR_KEY_VALUE), help="Variables to pass to the template context, and their value")

    return parser.parse_args(av)

def main(ac, av):
    ## If we only want a list of the available templates, we print them and quit
    if "-l" in av or "--list" in av:
        list_template_names(Defaults.DIR_TEMPLATES)
        return 0

    args = get_args(av[1:])

    logging_level = logging.ERROR
    if args.debug:
        logging_level = logging.DEBUG
    elif args.verbose:
        logging_level = logging.INFO
    logging.basicConfig(level=logging_level, format="[%(asctime)s][%(levelname)s]: %(message)s")

    logging.debug("Checking for existence of directory \"{0}\"".format(args.templates))
    if not os.path.isdir(args.templates):
        logging.critical("No such directory to load the templates from: \"{0}\"".format(args.templates))
        return 1

    logging.debug("Getting the path of the template file")
    ## Although nargs was set to 1 in the add_argument call, this variable still contains a list
    args.template = args.template[0]
    template_path = get_template_path(args.templates, args.template)
    if not template_path:
        logging.critical("No such template: \"{0}\"".format(args.template))
        return 1

    logging.info("Template located at \"{0}\"".format(template_path))

    new_file = os.path.join(os.getcwd(), os.path.basename(template_path))
    if args.filename:
        new_file = args.filename

    logging.debug("Creating the new context for template generation")
    context = {}
    for var in args.vars:
        key_value_pair = var.split(args.separator, 1)
        if len(key_value_pair) > 1:
            context[key_value_pair[0]] = key_value_pair[1]

    logging.debug("Context as parsed from the command line interface: {0}".format(context))

    logging.info("The new file will be created at \"{0}\"".format(new_file))
    if not render_template(template_path, new_file, context):
        return 1

    return 0

if __name__ == "__main__":
    sys.exit(main(len(sys.argv), sys.argv))
