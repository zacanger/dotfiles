#!/usr/bin/env python

import sys
import json
import yaml

json_data = json.loads(open(sys.argv[1]).read())
converted_json_data = json.dumps(json_data)
print(yaml.dump(yaml.load(converted_json_data), default_flow_style=False))
