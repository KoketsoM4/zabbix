 # MySQL Database Connection Configuration
db_user='root'
db_host='10.200.203.226'
db_port='3306' 
db_password='4@Digits'
db_database='zabbix'


# MySQL Query Parameters
item_id='55361'
end_time=$(date +"%Y-%m-%d %H:%M:%S")
start_time=$(date -d '1 day ago' +"%Y-%m-%d %H:%M:%S")


# MySQL Query
query="
    SELECT CONCAT(FROM_UNIXTIME(clock), '  |  ', value) AS TimeStamp_and_Value
    FROM history
    WHERE itemid = ${item_id}
      AND clock BETWEEN UNIX_TIMESTAMP('${start_time}') AND UNIX_TIMESTAMP('${end_time}')
    ORDER BY clock;
"

# Output Directory
output_directory="/u02/TpsCsv/DONE/"

# Ensure the directory exists, create it if not
if [ ! -d "$output_directory" ]; then
    mkdir -p "$output_directory"
fi

# Generate a unique timestamp for the filename
timestamp=$(date +"%Y%m%d%H%M%S")

# Output CSV File with timestamp
output_file="${output_directory}MiddlewareTPS_${timestamp}.csv"

# Function to Execute MySQL Query and Export to CSV
execute_query_and_export() {

echo "db_host: ${db_host}"
echo "db_user: ${db_user}"
echo "db_password: ${db_password}"
echo "db_database: ${db_database}"
echo "query: ${query}"
echo "db_port: ${db_port}"

    mysql -h"${db_host}" -P"${db_port}" -u"${db_user}" -p"${db_password}" -D"${db_database}" -e "${query}" | tail -n +2 > "${output_file}"


    echo "Data exported successfully to: ${output_file}"
}

# Execute the function
execute_query_and_export

# Retention Policy: Keep the last 7 CSV files
max_files=7
current_files=$(ls -1 ${output_directory}MiddlewareTPS_*.csv 2>/dev/null | wc -l)

if [ "$current_files" -gt "$max_files" ]; then
    # Sort files by modification time and delete the oldest ones
    ls -1t ${output_directory}MiddlewareTPS_*.csv | tail -n +$((max_files + 1)) | xargs rm
fi
chown oracle:oracle "${output_directory}"*.csv

