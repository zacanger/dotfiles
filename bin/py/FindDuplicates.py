#!/usr/bin/env python3
'''
FindDuplicates.py
Version 1
Created by Wohlfe
'''

import sys
import os
import hashlib

def chunk_reader(fobj, chunk_size=1024):
    """Generator that reads a file in chunks of bytes"""
    while True:
        chunk = fobj.read(chunk_size)
        if not chunk:
            return
        yield chunk

def check_for_duplicates(paths, hash=hashlib.md5):
    hashes = {}
    dupes = []
    output_filename = os.path.join(os.path.curdir, 'FindDuplicates.txt') #Log file
    min_file_size = 2000000 #Minimum file size to find, default 2 MB

    with open(output_filename, 'w') as file_out:
        for path in paths:
            for dirpath, dirnames, filenames in os.walk(path):
                for filename in filenames:
                        full_path = os.path.join(dirpath, filename)
                        hashobj = hash()

                        for chunk in chunk_reader(open(full_path, 'rb')):
                            hashobj.update(chunk)

                        file_id = (hashobj.digest(), os.path.getsize(full_path))
                        duplicate = hashes.get(file_id, None)

                        if duplicate and not any(full_path in files for files in dupes) and os.path.getsize(full_path) >= min_file_size:
                            print("Duplicate found: %s and %s" % (full_path, duplicate))
                            dupes.append(full_path)

                            try:
                                file_out.write(full_path + ' and ' + duplicate + ', size: ' + str(os.path.getsize(full_path)) + '\n') #If everything check out, this writes it to the file.
                            except UnicodeEncodeError:
                                file_out.write(full_path.encode('ascii', 'ignore') + ' and ' + duplicate.encode('ascii', 'ignore') + ', size: ' + str(os.path.getsize(full_path)) + '\n') #Catches Unicode errors caused by files with names Windows can't handle

                        else:
                            hashes[file_id] = full_path

    file_out.close() #Flushes the buffer to the file

    print("Completed. The output file is ", output_filename)

if sys.argv[1:]:
    check_for_duplicates(sys.argv[1:])
else:
    print("Please pass the paths to check as parameters to the script"
