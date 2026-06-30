#!/usr/bin/env python3
# write_steps.py — read api_response.json, write steps.json

import json, sys
from datetime import datetime

def to_24h(time_str):
    return datetime.strptime(time_str, "%I:%M %p").strftime("%H:%M")

with open(sys.argv[1] if len(sys.argv) > 1 else 'api_response.json') as f:
    data = json.load(f)

leg   = data['routes'][0]['legs'][0]
steps = []

for step in leg['steps']:
    mode = step['travelMode']
    td   = step.get('transitDetails')

    if mode == 'TRANSIT' and td:
        vehicle = td['transitLine']['vehicle']['name']['text']
        steps.append({
            'type'    : vehicle.upper(),
            'line'    : td['transitLine']['name'],
            'headsign': td['headsign'],
            'depart'  : td['stopDetails']['departureStop']['name'],
            'arrive'  : td['stopDetails']['arrivalStop']['name'],
            'dep_time': to_24h(td['localizedValues']['departureTime']['time']['text']),
            'arr_time': to_24h(td['localizedValues']['arrivalTime']['time']['text']),
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

# overall arrival = arr_time of last transit leg
transit_steps = [s for s in steps if s.get('arr_time')]
arrival = transit_steps[-1]['arr_time'] if transit_steps else None

out = {
    'distance': leg['localizedValues']['distance']['text'],
    'duration': leg['localizedValues']['duration']['text'],
    'arrival' : arrival,
    'steps'   : steps
}

with open('steps.json', 'w') as f:
    json.dump(out, f, indent=2)
