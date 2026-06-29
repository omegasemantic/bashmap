#!/usr/bin/env bash
# add_fav.sh — geocode address, confirm, add to config.json
# usage: ./add_fav.sh "305 Queen St Auckland" QTH

export $(grep -v '^#' .env | xargs)

ADDRESS="$1"
CODE="${2^^}"  # uppercase

if [[ -z "$ADDRESS" || -z "$CODE" ]]; then
    echo "Usage: ./add_fav.sh \"address\" CODE"
    exit 1
fi

# geocode
ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$ADDRESS'))")
RESULT=$(curl -s "https://maps.googleapis.com/maps/api/geocode/json?address=${ENCODED}&key=${GMAPS_API_KEY}")

STATUS=$(echo "$RESULT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['status'])")

if [[ "$STATUS" != "OK" ]]; then
    echo "ERROR: geocode returned $STATUS"
    exit 1
fi

# extract place_id and formatted address
python3 -c "
import json, sys
d    = json.load(open('/dev/stdin'))
r    = d['results'][0]
pid  = r['place_id']
addr = r['formatted_address']
url  = f'https://www.google.com/maps/place/?q=place_id:{pid}'
print(f'Code     : $CODE')
print(f'Address  : {addr}')
print(f'Place ID : {pid}')
print(f'Map      : {url}')
print()
print(f'Confirm? [y/N] ', end='', flush=True)
" <<< "$RESULT"

read -r CONFIRM
if [[ "${CONFIRM,,}" != "y" ]]; then
    echo "Cancelled"
    exit 0
fi

# extract place_id and write to config.json
python3 -c "
import json
with open('config.json') as f:
    config = json.load(f)
result = json.loads('''$RESULT''')
pid = result['results'][0]['place_id']
config['$CODE'] = pid
with open('config.json', 'w') as f:
    json.dump(config, f, indent=2)
print('$CODE added to config.json')
"
