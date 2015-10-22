#!/usr/bin/python3 -tt
# Copyright (C) 2014 Tobias Klausmann <klausman@schwarzvogel.de>
# License: GPL-2

"""
Soak up stderr and stdout of program, emit them if its return value is out of
scope.
"""

import argparse
import subprocess
import sys
import tempfile


def run_command(command, hide_retcodes=None, nostdout=False, nostderr=False):
    """
    Run 'command' and swallow its stdout and stderr. 

    If the returncode is not in hide_retcodes, dump the command's stdout and
    stderr to our own instances of those streams, unless nostdout/nostderr are
    True.

    Note that command must be a string. Using a sequence does not work due to 
    the way subprocess.check_output() is implemented on Unix.

    Returns: the return code of the command
    """

    if hide_retcodes is None:
        hide_retcodes = [2]

    returncode = 0
    output = ""

    # Since we can handle only stdout xor stderr and subprocess.check_output()
    # does stdout for us, we have to pipe stderr somewhere for later use.
    # The tempfile module handles cleanup for us as soon as stderrfile leaves
    # scope.
    stderrfile = tempfile.TemporaryFile()

    try:
        output = subprocess.check_output(
            command, stderr=stderrfile, shell=True)
    except (subprocess.CalledProcessError) as exc:
        returncode = exc.returncode
        output = exc.output

    if returncode not in hide_retcodes:
        stderrfile.seek(0)
        if not nostderr:
            sys.stderr.write(stderrfile.read().decode())
        if not nostdout:
            sys.stdout.write(output.decode())

    return returncode


def main():
    """Main program"""
    parser = argparse.ArgumentParser(
        description=('Soak up stderr and stdout of program, emit them if its '
                     'return value is out of scope'))
    parser.add_argument("command", help="command to use")
    parser.add_argument("args", help="command args", nargs=argparse.REMAINDER)
    parser.add_argument("--retcodes", default="0",
                        help="Return codes to consider non-failures")
    parser.add_argument("--nostdout", action="store_true",
                        help="Discard stdout in case of failure.")
    parser.add_argument("--nostderr", action="store_true",
                        help="Discard stderr in case of failure.")

    args = parser.parse_args()

    retcodes = [int(x) for x in args.retcodes.split(",")]

    command = "%s %s" % (args.command, " ".join(args.args))

    sys.exit(
        run_command(command, retcodes, args.nostdout, args.nostderr))


if __name__ == "__main__":
    main()
