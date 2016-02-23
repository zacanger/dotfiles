#!/usr/bin/env python3
'''
FindFileType.py
Version 2.0
Created by Wohlfe

Find file types by extension and size on a local volume or mapped drive. Requires Python 3 and access to the folders/files.
'''

import os
import sys

def file_type_search(dir):
    extensions = ('.exe', '.vmdk', '.mp3') #Default extensions to be searched for, i.e. you want to find all of these types.
    large_extensions = ('.txt', '.ppt', '.pptx') #Default extensions to be searched for only if bigger than size_limit
    huge_extensions = ('.pst', '.zip', '.rar',)
    large_limit = 100000000 #Size limit for large_extensions in bytes, default 100MB
    huge_limit = 2000000000 #Size limit for huge_extnesions, default 2GB
    output_filename = os.path.join(os.path.curdir, 'FileTypeSearch.txt') #Log file
    filenames = []
    large_filenames = []
    huge_filenames = []

    for r, d, f in os.walk(rootdir):
            for files in f:
                try:
                    if files.endswith(extensions):
                        filenames.append(os.path.join(r, files)) #Adds files with extensions being searched for

                    elif files.endswith(large_extensions) and os.path.getsize(os.path.join(r, files)) >= large_limit:
                        large_filenames.append(os.path.join(r, files)) #Adds files with extensions being searched for only if bigger than large_limit

                    elif files.endswith(huge_extensions) and os.path.getsize(os.path.join(r, files)) >= huge_limit:
                        huge_filenames.append(os.path.join(r, files)) #Adds files with extensions being searched for only if bigger than huge_limit
                except OSError as err:
                    print("Access Denied: ", err) #Catches OS errors for locked files
    
    filenames_sorted = sorted(set(filenames))
    large_filenames_sorted = sorted(set(large_filenames))
    huge_filenames_sorted = sorted(set(huge_filenames))

    with open(output_filename, 'w') as file_out:
        print("Unwanted Files:" + '\n')
        for filename in filenames_sorted:
            short_filename = filename[len(rootdir):] #Shortens the output, don't need the entire directory on every line.

            try:
                file_out.write('\t' + short_filename + '\n') #If everything check out, this writes it to the file.
            except UnicodeEncodeError:
                file_out.write(short_filename.encode('ascii', 'ignore') + '\n') #Catches Unicode errors caused by files with names Windows can't handle

        print("Oversized Files:" + '\n')
        for filename in large_filenames_sorted:
            short_large_filename = filename[len(rootdir):] 

            try:
                file_out.write('\t' + short_large_filename + '\n') 
            except UnicodeEncodeError:
                file_out.write('\t' + short_large_filename.encode('ascii', 'ignore') + '\n')

        print("Massive Files:" + '\n')
        for filename in huge_filenames_sorted:
            short_huge_filename = filename[len(rootdir):] 

            try:
                file_out.write('\t' + short_huge_filename + '\n') 
            except UnicodeEncodeError:
                file_out.write('\t' + short_huge_filename.encode('ascii', 'ignore') + '\n')

    file_out.close() #Flushes the buffer to the file

    print("Completed. The output file is ", output_filename)

if sys.version_info < (3, 0): 
    raise "You must use Python 3 or change the script." #Checks the Python version

if sys.argv[1:]:
    rootdir = sys.argv[1].rstrip() #Expects an argument, strips whitespace from it.
    file_type_search(root_dir) #Executes the function
else:
    sys.exit("This script requires a path to run on.") #Exits if no path is given.