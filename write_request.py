#!/usr/bin/env python3
import json, sys

origin_raw, dest_raw, type_, timestamp = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

with open('config.json') as f:
    codes = json.load(f)

with open('request.json') as f:
    req = json.load(f)

CITY = codes.get('_CITY', 'Auckland')
MODE = codes.get('_MODE', 'TRANSIT')
PREF = codes.get('_PREF', 'LESS_WALKING')
NZ   = ', New Zealand'

def resolve(token):
    token = token.strip()
    code  = token.upper()
    if code in codes:
        val = codes[code]
        if val.startswith('ChIJ'):
            return {'placeId': val}
        else:
            return {'address': val + NZ}
    else:
        return {'address': token + ', ' + CITY + NZ}

req['origin']                          = resolve(origin_raw)
req['destination']                     = resolve(dest_raw)
req['travelMode']                      = MODE
req['transitPreferences']              = {'routingPreference': PREF}
req['departureTime']                   = None
req['arrivalTime']                     = None

if type_ == 'DEP' and timestamp:
    req['departureTime'] = timestamp
elif type_ == 'ARR' and timestamp:
    req['arrivalTime'] = timestamp

with open('request.json', 'w') as f:
    json.dump(req, f, indent=2)
