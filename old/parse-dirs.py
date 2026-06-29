#!/usr/bin/env python3
"""parse_dirs.py — parse Directions API response.json to structured.json"""
import json, sys, re

def strip_html(s):
    return re.sub(r'<[^>]+>', '', s)

with open(sys.argv[1] if len(sys.argv) > 1 else 'response.json') as f:
    data = json.load(f)

leg = data['routes'][0]['legs'][0]
steps = []

for step in leg['steps']:
    mode = step['travel_mode']
    td   = step.get('transit_details')

    if mode == 'TRANSIT' and td:
        vehicle = td['line']['vehicle']['name']
        steps.append({
            'type'    : vehicle.upper(),
            'line'    : td['line']['name'],
            'headsign': td['headsign'],
            'depart'  : td['departure_stop']['name'],
            'arrive'  : td['arrival_stop']['name'],
            'dep_time': td['departure_time']['text'],
            'arr_time': td['arrival_time']['text'],
            'stops'   : td['num_stops']
        })
    elif mode == 'WALKING':
        for sub in step.get('steps', [step]):
            inst = strip_html(sub.get('html_instructions', ''))
            dist = sub['distance']['text']
            if inst:
                steps.append({'type': 'WALK', 'instruction': inst, 'distance': dist})

out = {
    'distance': leg['distance']['text'],
    'duration': leg['duration']['text'],
    'depart'  : leg['departure_time']['text'],
    'arrive'  : leg['arrival_time']['text'],
    'steps'   : steps
}

print(json.dumps(out, indent=2))
