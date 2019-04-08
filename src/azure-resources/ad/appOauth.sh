#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Extract "application_id" argument from the input into
# shell variable.
# jq will ensure that the values are properly quoted
# and escaped for consumption by the shell.
eval "$(jq -r '@sh "APPLICATION_ID=\(.application_id')"

# Placeholder for whatever data-fetching logic your script implements
OAUTH="$(az ad app show --id $APPLICATION_ID --query 'oauth2Permissions[0].id' -o tsv)"

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg oauth_id "$OAUTH" '{"oauth_id":$oauth_id}'