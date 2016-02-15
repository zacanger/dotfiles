#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Created by Aaron Caffrey
# License: GPLv3
import os
import tarfile
import logging
from glob import glob
from time import strftime
from shutil import move, rmtree
from sys import exit, argv, path, stderr
# try to import the config file as module
try:
    path.append(os.getenv("HOME") + "/.config/")
    from backup_like_king import blk
except ImportError:
    pass

class log_errors:
  def __init__(self):
    self.logger = logging.getLogger(__name__)
    self.logger.setLevel(logging.INFO)

    # create a file handler
    self.handler = logging.FileHandler(os.getenv("HOME") + '/fail-log-{0}.log'.format(strftime("%H:%M")))
    self.handler.setLevel(logging.INFO)

    # create a logging format
    self.formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    self.handler.setFormatter(self.formatter)

    # add the handlers to the logger
    self.logger.addHandler(self.handler)

    # print the errors to the terminal too
    self.console = logging.StreamHandler()
    self.console.setLevel(logging.INFO)
    self.console.setFormatter(self.formatter)
    self.logger.addHandler(self.console)


class CallBack(object):

    def __init__(self, fobj, callback):
        self.fobj = fobj
        self.callback = callback
        self.size = os.fstat(self.fobj.fileno()).st_size

    def read(self, size):
        self.callback(self.fobj.tell(), self.size)
        return self.fobj.read(size)

    def close(self):
        self.callback(self.size, self.size)
        self.fobj.close()


class TarDatFile(tarfile.TarFile):

    def __init__(self, *args, **kwargs):
        self.callback = kwargs.pop("callback")
        super(TarDatFile, self).__init__(*args, **kwargs)

    def addfile(self, tarinfo, fileobj=None):
        if self.callback is not None and fileobj is not None:
            fileobj = CallBack(fileobj, self.callback)
        super(TarDatFile, self).addfile(tarinfo, fileobj)

class backup_like_king2:

    def callback(self, processed, total):
        stderr.write("Progress: %{0:.1f} \r".format(processed / float(total) * 100))

    def remove_duplicate_directories(self, items):
        list_set = set()
        for item in items:
            if item not in list_set:
                yield item
            list_set.add(item)

    def remove_new_lines(self):
        with open(os.getenv("HOME") + "/.config/backup_like_king.py", "r") as conf:
            lines = conf.readlines()
        with open(os.getenv("HOME") + "/.config/backup_like_king.py", "w") as conf:
            [conf.write(line) for line in lines if line.strip()]

    def __init__(self):

        # nobody wants bytecompiled version of the program, so the new changes won't go in conflict
        if os.path.exists(os.getenv("HOME") + "/.config/__pycache__"):
            rmtree(os.getenv("HOME") + "/.config/__pycache__")

        # root is not allowed to run the program
        if os.geteuid() == 0:
            exit("\nYou can\'t run this program as root.\n")

        # if command line arguments persist...
        if len(argv) > 1:
            # replace specific directory with another from the list
            if argv[1] == "-replace":
                if os.path.exists(os.getenv("HOME") + "/.config/__pycache__"):
                    rmtree(os.getenv("HOME") + "/.config/__pycache__")
                with open(os.getenv("HOME") + "/.config/backup_like_king.py") as infile, open(os.getenv("HOME") + "/.config/backup_like_king2.py","w") as outfile:
                    for i,line in enumerate(infile):
                        if i == 2:
                            copy_list = blk.dirs_to_backup[:]
                            path_to_delete = copy_list.index("{0}".format(argv[2]))
                            del copy_list[path_to_delete]
                            copy_list.append("{0}".format(argv[3]))
                            outfile.write("    dirs_to_backup = {0}\n".format(copy_list))
                        else:
                            outfile.write(line)
                move(os.getenv("HOME") + "/.config/backup_like_king2.py", os.getenv("HOME") + "/.config/backup_like_king.py")

            # print all of the directories in the list
            if argv[1] == "-list":
                if os.path.exists(os.getenv("HOME") + "/.config/__pycache__"):
                    rmtree(os.getenv("HOME") + "/.config/__pycache__")
                print(str(blk.dirs_to_backup).replace("[", "").replace("'", "").replace('"', '').replace("]", ""))
                exit()

            # delete specific directory from the list
            if argv[1] == "-delete":
                if os.path.exists(os.getenv("HOME") + "/.config/__pycache__"):
                    rmtree(os.getenv("HOME") + "/.config/__pycache__")
                with open(os.getenv("HOME") + "/.config/backup_like_king.py") as infile, open(os.getenv("HOME") + "/.config/backup_like_king2.py","w") as outfile:
                    for i,line in enumerate(infile):
                        if i == 2:
                            copy_list = blk.dirs_to_backup[:]
                            if len(argv[1:]) > 2:
                                path_to_delete = copy_list.index("{0}".format(" ".join(argv[2:])))
                                del copy_list[path_to_delete]
                                outfile.write("    dirs_to_backup = {0}\n".format(copy_list))
                            else:
                                path_to_delete = copy_list.index("{0}".format(argv[2]))
                                del copy_list[path_to_delete]
                                outfile.write("    dirs_to_backup = {0}\n".format(copy_list))
                        else:
                            outfile.write(line)
                move(os.getenv("HOME") + "/.config/backup_like_king2.py", os.getenv("HOME") + "/.config/backup_like_king.py")

            # add directory to the list
            if argv[1] == "-add":
                if os.path.exists(os.getenv("HOME") + "/.config/__pycache__"):
                    rmtree(os.getenv("HOME") + "/.config/__pycache__")
                with open(os.getenv("HOME") + "/.config/backup_like_king.py") as infile, open(os.getenv("HOME") + "/.config/backup_like_king2.py","w") as outfile:
                    for i,line in enumerate(infile):
                        if i == 2:
                            if len(argv[1:]) > 2:
                                copy_list = blk.dirs_to_backup[:]
                                copy_list.append("{0}".format(" ".join(argv[2:])))
                                outfile.write("    dirs_to_backup = {0}\n".format(list(self.remove_duplicate_directories(copy_list))))
                            else:
                                copy_list = blk.dirs_to_backup[:]
                                copy_list.append("{0}".format(argv[2]))
                                outfile.write("    dirs_to_backup = {0}\n".format(list(self.remove_duplicate_directories(copy_list))))
                        else:
                            outfile.write(line)
                move(os.getenv("HOME") + "/.config/backup_like_king2.py", os.getenv("HOME") + "/.config/backup_like_king.py")

            # change the backup location
            if argv[1] == "-location":
                if os.path.exists(os.getenv("HOME") + "/.config/__pycache__"):
                    rmtree(os.getenv("HOME") + "/.config/__pycache__")
                with open(os.getenv("HOME") + "/.config/backup_like_king.py") as infile, open(os.getenv("HOME") + "/.config/backup_like_king2.py","w") as outfile:
                    for i,line in enumerate(infile):
                        if i == 4:
                            if len(argv[1:]) > 2:
                                outfile.write("    backup_location = '{0}'\n".format(" ".join(argv[2:])))
                            else:
                                outfile.write("    backup_location = '{0}'\n".format(argv[2]))
                        else:
                            outfile.write(line)
                move(os.getenv("HOME") + "/.config/backup_like_king2.py", os.getenv("HOME") + "/.config/backup_like_king.py")

            # change the md5sum to 'yes'
            if argv[1] == "-md5sum-on":
                if os.path.exists(os.getenv("HOME") + "/.config/__pycache__"):
                    rmtree(os.getenv("HOME") + "/.config/__pycache__")
                with open(os.getenv("HOME") + "/.config/backup_like_king.py") as infile, open(os.getenv("HOME") + "/.config/backup_like_king2.py","w") as outfile:
                    for i,line in enumerate(infile):
                        if i == 6:
                            outfile.write("    md5sum = 'Yes'\n")
                        else:
                            outfile.write(line)
                move(os.getenv("HOME") + "/.config/backup_like_king2.py", os.getenv("HOME") + "/.config/backup_like_king.py")

            # change the md5sum to 'no'
            if argv[1] == "-md5sum-off":
                if os.path.exists(os.getenv("HOME") + "/.config/__pycache__"):
                    rmtree(os.getenv("HOME") + "/.config/__pycache__")
                with open(os.getenv("HOME") + "/.config/backup_like_king.py") as infile, open(os.getenv("HOME") + "/.config/backup_like_king2.py","w") as outfile:
                    for i,line in enumerate(infile):
                        if i == 6:
                            outfile.write("    md5sum = 'No'\n")
                        else:
                            outfile.write(line)
                move(os.getenv("HOME") + "/.config/backup_like_king2.py", os.getenv("HOME") + "/.config/backup_like_king.py")

            # change the backup archive format
            if argv[1] == "-archive-format":
                if not argv[2] in ["bz2", "gz"]:
                    exit("\n{0} is not a valid archive format or it\'s not supported by the python\'s tarfile module.\n".format(argv[2]))
                else:
                    if os.path.exists(os.getenv("HOME") + "/.config/__pycache__"):
                        rmtree(os.getenv("HOME") + "/.config/__pycache__")
                    with open(os.getenv("HOME") + "/.config/backup_like_king.py") as infile, open(os.getenv("HOME") + "/.config/backup_like_king2.py","w") as outfile:
                        for i,line in enumerate(infile):
                            if i == 8:
                                outfile.write("    archive_format = '{0}'\n".format(argv[2]))
                            else:
                                outfile.write(line)
                    move(os.getenv("HOME") + "/.config/backup_like_king2.py", os.getenv("HOME") + "/.config/backup_like_king.py")
                    with open(os.getenv("HOME") + "/.config/backup_like_king.py") as infile, open(os.getenv("HOME") + "/.config/backup_like_king2.py","w") as outfile:
                        for i,line in enumerate(infile):
                            if i == 9:
                                outfile.write("    archive_extension = 'tar.{0}'\n".format(argv[2]))
                            else:
                                outfile.write(line)
                    move(os.getenv("HOME") + "/.config/backup_like_king2.py", os.getenv("HOME") + "/.config/backup_like_king.py")

            # purge the existing profile
            if argv[1] == "-purge-profile":
                if os.path.exists(os.getenv("HOME") + "/.config/__pycache__"):
                    rmtree(os.getenv("HOME") + "/.config/__pycache__")
                if os.path.isfile(os.getenv("HOME") + "/.config/backup_like_king.py"):
                    os.remove(os.getenv("HOME") + "/.config/backup_like_king.py")
                    exit("\nThe profile file was deleted successfully.\n")
                else:
                    exit("\nThe profile file does NOT exists.\n")

            # if the cmd args does not match the criterion below, call help
            if not argv[1] in ["-purge-profile", "-archive-format", "-md5sum-off",
"-list", "-add", "-delete", "-md5sum-on", "-replace", "-location"]:
                if os.path.exists(os.getenv("HOME") + "/.config/__pycache__"):
                    rmtree(os.getenv("HOME") + "/.config/__pycache__")
                Call().Help()

        # if the config file does not exist, ask few questions
        if not os.path.isfile(os.getenv("HOME") + "/.config/backup_like_king.py"):
            if os.path.exists(os.getenv("HOME") + "/.config/__pycache__"):
                rmtree(os.getenv("HOME") + "/.config/__pycache__")

            self.dirs_list = []

            # feed the hungry list
            self.supply_dirs = input("\nHello, please supply the desired directories\nand or files that we will backup.\nUse comma to separate them (dir1,dir2,somefile)\n")

            # dir1,dir2 -> 'dir1','dir2'
            self.split_dirs = self.supply_dirs.split(",")

            # ['dir1','dir2']
            self.dirs_list.append(self.split_dirs)

            # write down the supplied directories
            with open(os.getenv("HOME") + "/.config/backup_like_king.py", "w") as conf_file:
                for dirs in self.dirs_list:
                    conf_file.write("class blk:\n    ")
                    conf_file.write("# [ directories ]\n    ")
                    conf_file.write("dirs_to_backup = {0}\n    ".format(dirs))

            # backup location question
            self.backup_location_q = input("\nWhere to store each backup, supply the directory: ( /home/user/path/to/folder/ )\n")
            if not os.path.exists(self.backup_location_q):
                try:
                    os.mkdir("{0}".format(self.backup_location_q))
                except:
                    os.remove(os.getenv("HOME") + "/.config/backup_like_king.py")
                    exit("\n{0} is not a valid path, lol. Run the program again and supply correct details.\n".format(self.backup_location_q))

            if os.path.exists(self.backup_location_q):
                with open(os.getenv("HOME") + "/.config/backup_like_king.py", "a") as conf_file:
                    conf_file.write("# [ backup location ]\n    ")
                    conf_file.write("backup_location = '{0}'\n    ".format(self.backup_location_q))

            # md5sum question
            self.md5sum_log_q = input("\nDo you want to create automatically md5sum logs for each backup ? ( y/n )\n")
            if self.md5sum_log_q == "y":
                with open(os.getenv("HOME") + "/.config/backup_like_king.py", "a") as conf_file:
                    conf_file.write("# [ md5sum ]\n    ")
                    conf_file.write("md5sum = 'Yes'\n    ")
            else:
                with open(os.getenv("HOME") + "/.config/backup_like_king.py", "a") as conf_file:
                    conf_file.write("# [ md5sum ]\n    ")
                    conf_file.write("md5sum = 'No'\n    ")

            # backup archive format question
            self.backup_archive_format_q = input("\nIn what format should each backup be created ?\n( bz2,gz ) Type some of these 2:\n")
            if not self.backup_archive_format_q in ["bz2","gz"]:
                os.remove(os.getenv("HOME") + "/.config/backup_like_king.py")
                exit("\n{0} is not a valid archive format or it\'s not supported by the python\'s tarfile module. Run the program again and supply correct details.\n".format(self.backup_archive_format_q))
            else:
                with open(os.getenv("HOME") + "/.config/backup_like_king.py", "a") as conf_file:
                    conf_file.write("# [ backup archive format ]\n    ")
                    conf_file.write("archive_format = '{0}'\n    ".format(self.backup_archive_format_q))
                    conf_file.write("archive_extension = 'tar.{0}'\n    ".format(self.backup_archive_format_q))

            if self.md5sum_log_q == "y":
                self.md5sum_to_print = "Yes"
            else:
                self.md5sum_to_print = "No"
            print("""
Well done, a profile file was created so whenever you run the program again,
the program will backup {0}
in {1}
md5sum reports: {2}
backup archive format: {3}
""".format(self.supply_dirs, self.backup_location_q, self.md5sum_to_print, self.backup_archive_format_q))
            exit()

        # config file exist, so continue
        if os.path.isfile(os.getenv("HOME") + "/.config/backup_like_king.py") and len(argv) <= 1:
            year = blk.backup_location + strftime("%Y")
            month = blk.backup_location + strftime("%Y") + "/" + strftime("%B")
            today = blk.backup_location + strftime("%Y") + "/" + strftime("%B") + "/" + strftime("%d")
            md5sum = blk.backup_location + strftime("%Y") + "/" + strftime("%B") + "/" + strftime("%d") + "/md5sum"
            fail_log = blk.backup_location + strftime("%Y") + "/" + strftime("%B") + "/" + strftime("%d") + "/fail_log"

            for x in blk.dirs_to_backup:
                ar2, ar4 = str(x).split(os.getenv("HOME"))

            ar3 = ar4.replace("['", "", 1).replace("/", "").replace('"', '').replace("/", "").replace("']", "", 1).replace("Desktop", "")

            if not os.path.exists(year):
                os.mkdir(year)
            if not os.path.exists(month):
                os.mkdir(month)
            if not os.path.exists(today):
                os.mkdir(today)
            if blk.md5sum == "Yes":
                if not os.path.exists(md5sum):
                    os.mkdir(md5sum)

            target = today + "/" + ar3 + "-" + strftime("%H:%M") + ".{0}".format(blk.archive_extension)

            if blk.archive_format == "bz2" or blk.archive_format == "gz":
                try:
                    print("\nCreating archive in {0}".format(target))
                    with TarDatFile.open("{0}".format(target), "w:{0}".format(blk.archive_format), callback=self.callback) as tar_archive:
                        for name in blk.dirs_to_backup:
                            tar_archive.add(name)
                            print("{0} was added to the archive".format(name))
                    if blk.md5sum == "Yes":
                        aa = target.split("/")
                        os.system("md5sum '{0}' > '{1}'".format(target, today + "/md5sum-{0}.txt".format(aa[7])))
                        os.chdir(today)
                        for files in glob("*.txt"):
                            move(files, "{0}/md5sum/{1}".format(today, files))
                        print("md5sum was generated to {0}".format(today + "/md5sum/md5sum-{0}.txt".format(aa[7])))
                    print("\nThe backup was successful.")
                except:
                    # record the failed backup attempt in log in a separate folder for the particular day
                    os.remove(target)
                    if not os.path.exists(fail_log):
                        os.mkdir(fail_log)
                    log_errors().logger.error('', exc_info=True)
                    move(os.getenv("HOME") + '/fail-log-{0}.log'.format(strftime("%H:%M")), fail_log)
                    print("The backup process failed. See the fail log.")

class Call:

    def Help(self):
        print("""
Options:
    -list   List all directories or files in the backup list.
    -delete   Delete specific path from the list. Type -list to find which directories are in it.
    -add   Add existing directory or file to the list, so the program will include it to the backup file.
    -replace   Replace existing directory or file from the list ( /old/path/  /new/path/ )
    -location  Change the backup location. ( /path/to/new/location/ )
    -archive-format  Change the file format for the backup archive. ( bz2,gz )
    -md5sum-off / -md5sum-on  Turn on or off the md5sum log report for each backup.
    -purge-profile  Delete the existing profile.

""")

if __name__ == '__main__':
    try:
        backup_like_king2()
    except (NameError, OSError):
        log_errors().logger.error('', exc_info=True)
        print("\nThere was some errors, see the fail log in your home directory.\n")