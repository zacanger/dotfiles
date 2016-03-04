#!/usr/bin/env python

# works with python 2 or 3

import os
from flask import Flask

app = Flask(__name__, static_url_path='', static_folder='.')
app.add_url_rule('/', 'root', lambda: app.send_static_file('index.html'))

if __name__ == '__main__':
  app.run(port=3000)

