#!/bin/bash

# read a structured input string
# string source: input.txt (pending form input)
# write request.json (first step in api chain)

# defaults
export $(grep -v '^#' .env | xargs)

# string format: [START].[DES].[ARR|DEP 0000]
input=$(cat input.txt | xargs)

# three-part split on .
IFS='.' read -r START DES TIMEFIELD <<< "$input"
START=$(echo "$START" | xargs)
DES=$(echo "$DES" | xargs)
TIMEFIELD=$(echo "$TIMEFIELD" | xargs)
TIMEFIELD="${TIMEFIELD^^}"  # uppercase before regex

# extract ARR|DEP and TIME
if [[ "$TIMEFIELD" =~ (ARR|DEP)[[:space:]]+([0-9]{4}) ]]; then
    TYPE="${BASH_REMATCH[1]}"
    TIME="${BASH_REMATCH[2]}"
else
    TYPE="DEP"
    TIME=""
fi

# build ISO 8601 timestamp if time provided
if [[ -n "$TIME" ]]; then
    HOUR="${TIME:0:2}"
    MIN="${TIME:2:2}"
    DATE=$(date +%Y-%m-%d)
    TIMESTAMP="${DATE}T${HOUR}:${MIN}:00+12:00"
else
    TIMESTAMP=""
fi

# write request.json (resolve favs, append city etc)
python3 write_request.py "$START" "$DES" "$TYPE" "$TIMESTAMP"

# breakpoint 1
echo "Origin  : $START"
echo "Dest    : $DES"
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
#cat api_response.json | python3 -c "import json,sys; d=json.load(sys.stdin); print('Status: OK' if 'routes' in d else 'ERROR: ' + str(d))"

# breakpoint 3

# reduce api response to relevant steps
python3 write_steps.py api_response.json > steps.json
echo "steps.json written"
# sanity check (delete/comment next line)
cat steps.json | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'Steps: {len(d[\"steps\"])}')"

# convert steps.json to human friendly form
# grep cuts short distances
python3 write_result.py |grep -vE 'WALK.*\([1-9] m\)|WALK.*\([12][0-9] m\)' > result.txt
#python3 write_result.py > result.txt




# eof
