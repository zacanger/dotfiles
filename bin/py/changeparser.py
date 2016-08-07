#!/usr/bin/python
# Extract changelog information from a version control repository.
# At the moment this only supports Git repositories.
# Adam Sampson <ats@offog.org>

import datetime
import os
import subprocess

class ChangeParserError(Exception):
	pass

class Commit(dict):
	"""A changeset in the repository.

	This is a dict containing any of the following fields, depending on the
	information available:

	"id": VCS ID for this changeset (matches [a-zA-Z0-9]+)
	"subject": one-line description of the changeset
	"body": full description of the changeset, with embedded newlines
	"authortime": a datetime object saying when the changeset was written
	"authorname": the changeset author's human-readable name
	"authoremail": the changeset author's email address
	"paths": list of PathChanges describing paths affected by this changeset

	Unless otherwise specified, values are unicode() objects.
	"""
	pass

class PathChange(dict):
	"""A path changed by a changeset.

	This is a dict containing any of the following fields, depending on the
	information available:

	"path": path relative to the top of the repository (e.g. u"foo/bar.c")
	"status": one of "added", "copied", "deleted", "modified", "renamed"

	Unless otherwise specified, values are unicode() objects.
	"""
	pass

GIT_STATUS_MAP = {
	u"A": "added",
	u"C": "copied",
	u"D": "deleted",
	u"M": "modified",
	u"R": "renamed",
	}

def get_changes_git(repo_path, max_changes=None):
	cmd = [
		"git", "log",
		"--name-status",
		"--pretty=tformat:id %H%nsubject %s%nauthortime %at%nauthorname %an%nauthoremail %ae%n%w(0,1,1)%B"
		]
	if max_changes is not None:
		cmd += ["-n", str(max_changes)]
	proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, cwd=repo_path)

	commits = []

	commit = None
	for line in proc.stdout.readlines():
		line = line.decode("UTF-8")
		fields = line[:-1].split(None, 1)
		if line == u"\n":
			pass
		elif line[0] == u" ":
			commit["body"] = commit.get("body", "") + line[1:]
		elif fields[0] == u"id":
			commit = Commit()
			commit["id"] = fields[1]
			commits.append(commit)
		elif fields[0] in GIT_STATUS_MAP:
			pchange = PathChange()
			pchange["path"] = fields[1]
			pchange["status"] = GIT_STATUS_MAP[fields[0]]
			commit.setdefault("paths", []).append(pchange)
		else:
			(key, value) = (str(fields[0]), fields[1])
			if key.endswith("time"):
				value = datetime.datetime.utcfromtimestamp(int(value))
			commit[key] = value

	if proc.wait() != 0:
		raise ChangeParserError("git command failed in " + repo_path + ": " + " ".join(cmd))

	return commits

def get_changes(repo_path, max_changes=None):
	"""Return a list of Commits in the given repository, detecting
	the type automatically.
	The list is sorted by time, with the newest changeset first.
	To only get the N most recent changesets, set max_changes to N."""

	def exists(path):
		return os.access(path, os.F_OK)

	if exists(repo_path + "/refs"):
		# Git bare repo.
		return get_changes_git(repo_path, max_changes)
	elif exists(repo_path + "/.git/refs"):
		# Git regular repo.
		return get_changes_git(repo_path + "/.git", max_changes)
	else:
		raise ChangeParserError("Unknown repository type: " + repo_path)

if __name__ == "__main__":
	import sys
	import pprint
	for arg in sys.argv[1:]:
		print arg + ":"
		pprint.pprint(get_changes(arg))
