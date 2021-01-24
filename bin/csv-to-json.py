#!/usr/bin/env python3

import csv
import json


def csv_to_json(csv_path):
    json_array = []
    json_path = csv_path.replace('.csv', '.json')

    with open(csv_path, encoding='utf-8') as f:
        reader = csv.DictReader(f)

        for row in reader:
            json_array.append(row)

    with open(json_path, 'w', encoding='utf-8') as f:
        json_string = json.dumps(json_array, indent=4)
        f.write(json_string)


csv_to_json(sys.argv[1])
