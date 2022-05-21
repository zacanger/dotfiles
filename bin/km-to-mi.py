#!/usr/bin/env python

import sys

CONV_FAC = 0.621371
WHICH_WAY = int(input("Enter 1 for km to miles, 2 for miles to km: "))

if WHICH_WAY == 1:
    km = float(input("Enter km: "))
    miles = km * CONV_FAC
    print("%0.2f km is %0.2f miles" % (km, miles))
elif WHICH_WAY == 2:
    miles = float(input("Enter miles: "))
    km = miles / CONV_FAC
    print("%0.2f miles is %0.2f km" % (miles, km))
else:
    print("Invalid choice!")
    sys.exit(1)
