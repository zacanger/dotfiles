#!/usr/bin/env python

import sys
import os

os.system(" pyrcc4 ./src/browser/mainwindow.qrc -o ./src/browser/mainwindow_rc.py ")
from ez_setup import use_setuptools
use_setuptools('0.6c3')

from setuptools import setup, find_packages, Extension
from distutils.sysconfig import get_python_inc
from glob import glob
import commands

dist = setup(name='pyqt-browser',
    version='0.01',
    author='Erin Yueh',
    author_email='erin_yueh@openmoko.com',
    description='a webkit browser example by python qt ',
    url='http://code.google.com/p/pyqt-browser/',
    download_url='http://code.google.com/p/pyqt-browser/downloads/list',
    license='GNU GPL',
    package_dir={'':'src'},
    packages=['browser'],
    scripts=['src/webbrowser.py'],
    #install_requires=['python-pyqt>=4.4.3'],
    #setup_requires=['python-pyqt>=4.4.3'],
    data_files=[
    ('pixmaps',['data/pyqt-browser.png']),
    ('applications', ['data/pyqt-browser.desktop'])
]
)

installCmd = dist.get_command_obj(command="install_data")
installdir = installCmd.install_dir
installroot = installCmd.root

if not installroot:
    installroot = ""

if installdir:
    installdir = os.path.join(os.path.sep,
        installdir.replace(installroot, ""))
