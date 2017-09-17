#!/usr/bin/env python

import random
import string
import sys

if __name__ == '__main__':
    try:
        n = int(sys.argv[1])
    except:
        n = 16

    print(
        ''.join(
            random.SystemRandom().choice(
                string.ascii_letters + string.digits
            ) for _ in range(n)
        )
    )

