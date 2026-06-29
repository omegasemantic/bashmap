#!/bin/bash

# read a structured input string 
# string source: input.txt (pending form input)
# write request.json (first step in api chain)

# defaults
# GMPAP_API=(read .env)
# DEP=NOW
# MODE=TRN
# separator (SEP)
SEP="+"

# string format: [START_CUR][SEP][DES] [ARR|DEP] [24 HOUR TIME 0000] 

# pseudo
#read $input.txt

#extract and assign using bash string functions
#$START_CUR, $DES, $ARR , $DEP, $TIME

#amend request.json

# breakpoint 1

#curl routes.api < request.json > repsonse.json

parse-dirs.py < response.json > steps.json

#write_result.html.sh  < steps.json
