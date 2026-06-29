#!/bin/bash

# read a structured input string
# string source: input.txt (pending form input)
# write request.json (first step in api chain)

# defaults
export $(grep -v '^#' .env | xargs)
SEP="."
#CITY=", Auckland, New Zealand"
#MODE="TRANSIT"
#PREF="LESS_WALKING"

# string format: [START][SEP][DES] [ARR|DEP] [0000]
input=$(cat input.txt | xargs)

# split on separator
START="${input%%${SEP}*}"
REST="${input#*${SEP}}"
START=$(echo "$START" | xargs)

# extract ARR|DEP and TIME from REST
if [[ "$REST" =~ (ARR|DEP)[[:space:]]+([0-9]{4}) ]]; then
    TYPE="${BASH_REMATCH[1]}"
    TIME="${BASH_REMATCH[2]}"
    DES=$(echo "$REST" | sed "s/${TYPE}.*//")
else
    TYPE="DEP"
    TIME=""
    DES="$REST"
fi
DES=$(echo "$DES" | xargs)

# build ISO 8601 timestamp if time provided
if [[ -n "$TIME" ]]; then
    HOUR="${TIME:0:2}"
    MIN="${TIME:2:2}"
    DATE=$(date +%Y-%m-%d)
    TIMESTAMP="${DATE}T${HOUR}:${MIN}:00+12:00"
else
    TIMESTAMP=""
fi

# build address strings
ORIGIN="${START}${CITY}"
DEST="${DES}${CITY}"

# write request.json
python3 write_request.py "$ORIGIN" "$DEST" "$TYPE" "$TIMESTAMP"

# breakpoint 1

echo "Origin  : $ORIGIN"
echo "Dest    : $DEST"
echo "Type    : $TYPE"
echo "Time    : $TIMESTAMP"
echo "request.json written"

# breakpoint 2

# curl request to API < request.json > api_response.json
curl -s -X POST "https://routes.googleapis.com/directions/v2:computeRoutes" \
  -H "Content-Type: application/json" \
  -H "X-Goog-Api-Key: ${GMAPS_API_KEY}" \
  -H "X-Goog-FieldMask: routes.duration,routes.distanceMeters,routes.legs" \
  -d @request.json > api_response.json

echo "api_response.json written"
# sanity check (delete/comment next line) 
cat api_response.json | python3 -c "import json,sys; d=json.load(sys.stdin); print('Status: OK' if 'routes' in d else 'ERROR: ' + str(d))"

# breakpoint 3

# reduce api respose to relevant steps
# write_steps.py < api_response.json > steps.json
python3 write_steps.py api_response.json > steps.json
echo "substeps.json written"
# sanity check (delete/comment next line)
cat steps.json | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'Steps: {len(d[\"steps\"])}')"

# convert step.jason to human friendly form
# write_result.sh < steps.json > result.txt 
python3 write_result.py > result.txt
