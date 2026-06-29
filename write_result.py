#!/usr/bin/env python3
# write_steps.py — read steps.json, print plain text summary

import json

with open('steps.json') as f:
    data = json.load(f)

print(f"Distance : {data['distance']}")
print(f"Duration : {data['duration']}")
print()

for step in data['steps']:
    if step['type'] == 'WALK':
        print(f"  WALK  : {step['instruction']} ({step['distance']})")
    else:
        print(f"  {step['type']:<5} : {step['line']} towards {step['headsign']}")
        print(f"          Depart {step['depart']} at {step['dep_time']}")
        print(f"          Arrive {step['arrive']} at {step['arr_time']}")
        print(f"          {step['stops']} stops")
        print()
