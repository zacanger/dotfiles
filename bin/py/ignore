#!/usr/bin/env python3

# ignore - download gitignore files from github
#
# Usage: ignore -h
#
# Author: Tasos Latsas
# Source: https://github.com/tlatsas/dotfiles/tree/master/bin

import os
import sys
import requests
import argparse
from base64 import b64decode

_REPO = "https://api.github.com/repos/github/gitignore"
__version__ = "1.0.1"

def cmd_parse():
    """parse command line arguments"""
    parser = argparse.ArgumentParser(
        description="Get gitignore files from github",
        epilog="See: https://github.com/github/gitignore")

    parser.add_argument("-v", "--version", action="version",
        version="%(prog)s {0}".format(__version__))

    subparsers = parser.add_subparsers(help="available commands", dest="command")
    lister = subparsers.add_parser("list", help="List remote templates")
    getter = subparsers.add_parser("get", help="Get remote templates")

    getter.add_argument("ignore", nargs="+", help="gitignore template(s)")

    getter.add_argument("-o", "--output-files", action="store_true",
        default=False, help=("Store templates in separate files as name.gitignore"
        " Default: show all template contents in STDOUT"))

    getter.add_argument("-m", "--merge", action="store_true", default=False,
        help="Store all template contents in a .gitignore file")

    getter.add_argument("-f", "--force", action="store_true", default=False,
        help="Overwrite any existing files without prompt")

    return parser.parse_args()


def _request_templates(url):
    """build a template list"""
    templates = {}
    response = requests.get(url)
    json_data = response.json()

    for entry in json_data:
        name = entry["name"]
        if name.endswith(".gitignore"):
            canonical_name = name.rsplit('.', 1)[0].lower()
            templates[canonical_name] = {
                'filename': name,
                'url': entry["url"],
            }

    return templates


def get_templates():
    """get all .gitignore templates from the repo"""
    # get language/frameworks etc
    url_contents = "/".join((_REPO, "contents"))
    templates = _request_templates(url_contents)

    # get global contents
    url_contents_global = "/".join((url_contents, "Global"))
    global_templates = _request_templates(url_contents_global)

    templates.update(global_templates)
    return templates


def get_template_contents(url):
    """get contents for requested template url"""
    response = requests.get(url)
    json_data = response.json()
    return json_data["content"]


def prompt_overwrite(filename):
    answer = input("{0} already exists. Ovewrite? [y/n]: ".format(filename))
    return answer.lower() in ('y', 'yes')


def save_gitignore(ignore_dict, force=False):
    """iterate over a gitignore dict and save each entry as a file"""
    for filename, data in ignore_dict.items():
        if os.path.exists(filename):
            if force == False and prompt_overwrite(filename) == False:
                continue

        with open(filename, 'w') as f:
            f.write(data)


if __name__ == "__main__":
    if len(sys.argv) == 1:
        sys.argv.append('get')

    args = cmd_parse()
    templates = get_templates()

    if args.command == "list":
        for template in templates.keys():
            print(template)
    else:
        # transform all requested templates in lowercase
        requested_templates = map(str.lower, args.ignore)

        # get all requested template contents
        # we create a new dictionary with keys the actual gitignore
        # template filenames
        contents = {}
        for tpl in requested_templates:
            if tpl in templates:
                contents[templates[tpl]["filename"]] = b64decode(
                    get_template_contents(templates[tpl]["url"])).decode("UTF-8")

        # we output the contents on separate files or in a unified .gitignore file
        if args.output_files:
            if args.merge:
                merged_contents = "".join(
                    [content for content in contents.values()]
                )
                contents = {'.gitignore': merged_contents}
            save_gitignore(contents, args.force)
        else:
            # print each template in STDOUT
            for tpl_value in contents.values():
                print(tpl_value)

