#!/usr/bin/python

'''Provides a text-editor based user interface for quickly changing the
filenames of all files in the current directory.

'''
import os

if __name__ == '__main__':
    instructions = """
    Directory List

    Change the filenames here to their new values, then save
    and exit.
    - The files are renamed in order. Be careful.
    - Any line beginning with '#' is ignored.
    - Whitespace at the beginning or end is stripped. If you
    want it, do it by hand.
    - Blank a line to delete the file.
    """
    instructions = instructions.strip()
    instructions = "\n".join(["# %s" % s for s in
            instructions.splitlines()])

    tempfile = os.tempnam()
    o = open(tempfile,'w')

    filelist = os.listdir("./")
    filelist.sort()
    o.write(instructions)
    o.write("\n")
    o.write("\n".join(filelist))
    o.close()

    editor = os.environ.get('EDITOR',"vi")
    os.system("%s %s" % (editor,tempfile))

    o = open(tempfile)
    newfilelist = []
    for line in o:
        if line.startswith('#'): continue
        line = line.strip()
        newfilelist.append(line)
    o.close()
    os.remove(tempfile)
    step1src = []
    step1dst = []
    for (old, new) in zip(filelist, newfilelist):
        if old == new: continue
        if new in step1src:
            t = os.tempnam('./')
            step1src.insert(0,old)
            step1dst.insert(0,t)
            step1src.append(t)
            step1dst.append(new)
        else:
            step1src.append(old)
            step1dst.append(new)
    for (src,dst) in zip(step1src, step1dst):
        if dst:
            print "mv %s %s" % (src, dst)
            os.rename(src,dst)
        else:
            print "rm %s" % src
            os.remove(src)
