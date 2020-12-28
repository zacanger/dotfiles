#!/usr/bin/env python

import sys

conv_fac = 0.621371
which_way = int(input("Enter 1 for km to miles, 2 for miles to km: "))

if which_way == 1:
    km = float(input("Enter km: "))
    miles = km * conv_fac
    print("%0.2f km is %0.2f miles" % (km, miles))
elif which_way == 2:
    miles = float(input("Enter miles: "))
    km = miles / conv_fac
    print("%0.2f miles is %0.2f km" % (miles, km))
else:
    print("Invalid choice!")
    sys.exit(1)
