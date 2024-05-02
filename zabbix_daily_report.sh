#!/bin/bash

# MySQL Database Connection Configuration
db_host='10.200.203.226'
db_user='root'
db_password='4@Digits'
db_database='zabbix'

# MySQL Query
query="
    SELECT
        FROM_UNIXTIME(e.clock) AS event_time,
        e.name AS event_name,
        e.severity AS event_severity,
        t.description AS trigger_description,
        h.name AS host_visible_name,
        e.eventid AS problem_id
    FROM
        events e
            INNER JOIN triggers t ON e.objectid = t.triggerid
            INNER JOIN functions f ON t.triggerid = f.triggerid
            INNER JOIN items i ON f.itemid = i.itemid
            INNER JOIN hosts h ON i.hostid = h.hostid
    WHERE
            e.source = 0
      AND e.object = 0
      AND e.clock >= UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 24 HOUR));
"

# Output Directory
output_directory="/u02/ZabbixDailyReport/"

# Ensure the directory exists, create it if not
if [ ! -d "$output_directory" ]; then
    mkdir -p "$output_directory"
fi

# Generate a unique timestamp for the filename
timestamp=$(date +"%Y%m%d%H%M%S")

# Output CSV File with timestamp
output_file="${output_directory}zabbix_event_data_${timestamp}.csv"

# Function to Execute MySQL Query and Export to CSV
execute_query_and_export() {
    mysql -h"${db_host}" -u"${db_user}" -p"${db_password}" -D"${db_database}" -e "${query}" > "${output_file}"

    echo "Data exported successfully to: ${output_file}"
}

# Execute the function
execute_query_and_export

