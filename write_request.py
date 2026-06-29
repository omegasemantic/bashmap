#!/usr/bin/env python3
import json, sys

origin, dest, type_, timestamp = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

with open('request.json') as f:
    req = json.load(f)

req['origin']['address']      = origin
req['destination']['address'] = dest
req['departureTime']          = None
req['arrivalTime']            = None

if type_ == 'DEP' and timestamp:
    req['departureTime'] = timestamp
elif type_ == 'ARR' and timestamp:
    req['arrivalTime'] = timestamp

with open('request.json', 'w') as f:
    json.dump(req, f, indent=2)
