#!/bin/bash

# Set API endpoint
API_ENDPOINT='http://localhost:3005/v1/send'

# Set SMS parameters
SENDER='Middleware Alerts'

# Capture the message passed from Zabbix
MESSAGE="$1"

# Hardcode three destination numbers
DESTINATION1='243814444433'
DESTINATION2='243814444481'
DESTINATION3='243814444539'
DESTINATION4='243814444725'

# Iterate over each destination to send the SMS
for DESTINATION in "$DESTINATION1" "$DESTINATION2" "$DESTINATION3" "$DESTINATION4"
do
    # Send SMS using cURL
    curl --location "$API_ENDPOINT" \
         --header 'Content-Type: application/x-www-form-urlencoded' \
         --data-urlencode "dst=$DESTINATION" \
         --data-urlencode "src=$SENDER" \
         --data-urlencode "text=$MESSAGE"
done

