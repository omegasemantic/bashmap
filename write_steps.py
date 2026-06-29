#!/usr/bin/env python3
# parse_route.py — read response.json, write steps.json

import json, sys

with open(sys.argv[1] if len(sys.argv) > 1 else 'response.json') as f:
    data = json.load(f)

leg = data['routes'][0]['legs'][0]
steps = []

for step in leg['steps']:
    mode = step['travelMode']
    td   = step.get('transitDetails')

    if mode == 'TRANSIT' and td:
        vehicle = td['transitLine']['vehicle']['name']['text']  # fix
        steps.append({
            'type'    : vehicle.upper(),
            'line'    : td['transitLine']['name'],
            'headsign': td['headsign'],
            'depart'  : td['stopDetails']['departureStop']['name'],
            'arrive'  : td['stopDetails']['arrivalStop']['name'],
            'dep_time': td['localizedValues']['departureTime']['time']['text'],
            'arr_time': td['localizedValues']['arrivalTime']['time']['text'],
            'stops'   : td['stopCount']
        })
    elif mode == 'WALK':
        inst = step.get('navigationInstruction', {}).get('instructions')
        if inst:
            steps.append({
                'type'       : 'WALK',
                'instruction': inst,
                'distance'   : step['localizedValues']['distance']['text']
            })

out = {
    'distance': leg['localizedValues']['distance']['text'],
    'duration': leg['localizedValues']['duration']['text'],
    'steps'   : steps
}

with open('steps.json', 'w') as f:
    json.dump(out, f, indent=2)
