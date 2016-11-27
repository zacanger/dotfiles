#!/usr/bin/env python3

import sys
import tweepy


# CONSUMER_KEY = ""
# CONSUMER_SECRET = ""
# ACCESS_KEY = ""
# ACCESS_SECRET = ""

auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
auth.set_access_token(ACCESS_KEY, ACCESS_SECRET)
api = tweepy.API(auth)
api.update_status(sys.argv[1])
