#!/usr/bin/env python

# Invoke ImageMagick to display an image on the Linux framebuffer.
#
# We perform an ioctl() to find the fb's size. As we can't include C
# header files from Python, this is a little hacky. We hardcode the
# ioctl request number (FBIOGET_VSCREENINFO = 0x4600) and the size of
# the struct (sizeof struct fb_var_screeninfo = 160).
#
# To avoid artifacts at screen edges, we shrink the visible image by 5%.
#
# We also swap color channels around. "-endian lsb" does not work for
# some reason (there's an unresolved bug report at RedHat).
#
# When you want an interactive image viewer with zooming and everything,
# have a look at "fbida". Sadly, that program does not work when being
# called from inside of GNU screen, which is why I wrote this script.


from fcntl import ioctl
from os import fdopen, open, O_RDWR
from struct import unpack
from subprocess import call
from sys import argv, exit, stderr

if len(argv) < 2:
    print('Usage: {} <image>'.format(argv[0]), file=stderr)
    exit(1)

fd = open('/dev/fb0', O_RDWR)
raw_struct = ioctl(fd, 0x4600, ' ' * 160)
width, height = unpack('II152x', raw_struct)

vis_width = int(width * 0.95)
vis_height = int(height * 0.95)

sz_screen = '{}x{}'.format(width, height)
sz_vis = '>{}x{}'.format(vis_width, vis_height)

fo = fdopen(fd)
call(['convert', '-gravity', 'center', '-background', 'black',
      '-resize', sz_vis, '-extent', sz_screen, argv[1], '-separate',
      '-swap', '0,2', '-combine', 'rgba:-'], stdout=fo)
