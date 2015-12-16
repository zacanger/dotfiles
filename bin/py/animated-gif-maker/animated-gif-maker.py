#  Animated GIF maker Python script using ImageMagick
#
#  This file is part of the Animated GIF Maker project
#  by Philip J. Guo (Created April 2005)
#  http://alum.mit.edu/www/pgbovine/
#  Copyright 2005 Philip J. Guo
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

# This Python script uses the ImageMagick 'convert' program to make a
# square animated GIF from an input image and coordinate waypoint
# specifications written in a text file.

# Usage (4 arguments):
#  python animated-gif-maker.py
#    coordinates-file image-file final-size delay-between-frames

# coordinates-file: filename of a text file for describing the animation
#                   This can either be produced manually or by using the
#                   animated-gif-maker.html webpage
# image-file: input image file to be animated
# final-size: the width & height of the square output animated GIF
# delay-between-frames: how many 1/100 of a second to put between frames.
#                       This controls the speed of animation, along with
#                       the number of frames between waypoints as set in
#                       coordinates-file.

# The coordinates file consists of lines which represent waypoints:
# e.g.:
# 800 530 200 5
# 860 1050 900 10
# 1220 500 200 15

# Each line has the following fields: x y size num-frames
# x: center x-coordinate
# y: center y-coordinate
# size: width and height of the frame at the waypoint
#       (this serves as the zoom factor)
# frames: number of frames between the waypoint on the current line
#         and the waypoint on the next line

# The 'camera' will go from line to line, following the specifications
# which you provide, moving and zooming in a linear interpolation
# between the waypoints.  When it reaches the waypoint on the last
# line, it will loop back to the waypoint on the first line in order
# to create a smooth animation.  There is also support for just
# zooming without moving if you set two neighboring sets of x's and
# y's to be identical but with a different size (zoom factor).

# e.g.:
# 500 400 200 10
# 500 400 100 10

# This will start at a 200x200 section centered at 500x400 and zoom
# into a 100x100 section centered at the same coordinates, then zoom
# out back to a 200x200 section.

# Warnings:
# Be careful to not pick x, y, and size such that the square box of
# length size centered at (x, y) extends outside of the bounds of the
# picture. Otherwise, funky distorting behavior results, which is bad
# news.

import sys
import math
import os

input_fn = sys.argv[1]
image_filename = sys.argv[2]
final_size = sys.argv[3]
delay = sys.argv[4]

in_file = open(input_fn, 'r')

lines = in_file.readlines()

image_num = 0

stripped_lines = [x.strip() for x in lines]

current_x = -1
current_y = -1
current_size = -1

os.system ("rm -rf animated-gif-tmp")
os.system ("mkdir animated-gif-tmp")


# Create all of the frames using ImageMagick 'convert'
for ind in range(len(stripped_lines)):
    from_numbers = stripped_lines[ind].split()
    to_numbers = None
    
    # If we are on the last line, then use the first line as
    # to_numbers so that we can wrap around from the last waypoint
    # back to the first starting waypoint:
    if ind == (len(stripped_lines) - 1):
        to_numbers = stripped_lines[0].split()
    else:
        to_numbers = stripped_lines[ind + 1].split()

    from_x = 0
    from_y = 0
    
    if current_x >= 0:
        from_x = current_x # Prevents awkward distortions at corner points
    else:
        from_x = int(from_numbers[0])

    if current_y >= 0:
        from_y = current_y
    else:
        from_y = int(from_numbers[1])

    if current_size >= 0:
        from_size = current_size
    else:
        from_size = int(from_numbers[2])

    num_frames = int(from_numbers[3])

    to_x = int(to_numbers[0])
    to_y = int(to_numbers[1])
    to_size = int(to_numbers[2])

    x_dist = to_x - from_x
    y_dist = to_y - from_y

    # Make a straight line trajectory from from_[x,y] to to_[x,y]
    distance = math.sqrt(pow(x_dist, 2) + pow(y_dist, 2))

    cos_theta = 0
    sin_theta = 0

    current_x = from_x
    current_y = from_y
    current_size = from_size

    num_steps = 0
    update_amt = 0

    update_size_amt = float(to_size - from_size) / num_frames
    # Special case for stationary zooming case
    #    print "distance: ", distance
    # distance is a double so don't do 'if distance == 0'
    if (distance > 0.5):
        update_amt = float(distance) / num_frames
        cos_theta = float(x_dist) / distance
        sin_theta = float(y_dist) / distance

    for i in range(num_frames):
        image_num += 1

        # We want to center the image properly
        center_x = int(current_x - (current_size / 2))
        center_y = int(current_y - (current_size / 2))

        # Call the ImageMagick 'convert' program to generate the frame
        command = "convert " + image_filename + " -crop " + str(int(current_size)) + "x" + str(int(current_size)) + "+" + str(center_x) + "+" + str(center_y) +" -resize " + str(final_size) + "x" + str(final_size) + " " + "animated-gif-tmp/out_" + ('%03d' % image_num) + ".jpg"

        print command
        os.system(command)
        
        current_x += (update_amt * cos_theta)
        current_y += (update_amt * sin_theta)
        current_size += update_size_amt


# Call the ImageMagick 'convert' program to string all of the frames
# together into an animated GIF
print "Creating animated.gif ..."
os.system("convert -delay " + delay + " -loop 0 animated-gif-tmp/out_0*.jpg animated.gif")

os.system("rm -rf animated-gif-tmp")
print "Done creating animated.gif"
