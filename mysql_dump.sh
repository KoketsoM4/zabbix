#!/bin/bash

# MySQL Database Connection Configuration
db_host='10.200.203.226'
db_user='root'
db_password='4@Digits'
db_database='zabbix'

# Backup Directory
backup_directory="/u02/mysqldump/dumpbackup/"
log_directory="/u02/mysqldump/logs/"

# Ensure the directories exist, create them if not
mkdir -p "$backup_directory"
mkdir -p "$log_directory"

# Define the current date and time
current_datetime=$(date "+%Y%m%d%H%M%S")

# MySQL Dump and Compression
output=$(mysqldump --databases "$db_database" --log-error="$log_directory/errorlog_$current_datetime.txt" 2>&1 | gzip > "$backup_directory/Mysqldump-$current_datetime.sql.gz")

# Check if mysqldump command was successful
if [ $? -eq 0 ]; then
    echo "MySQL backup completed successfully at $(date) for database $db_database." >> "$log_directory/backuplog_$current_datetime.txt"
else
    echo "$(date +%Y-%m-%d\ %H:%M:%S) $output" >> "$log_directory/errorlog_$current_datetime.txt"
    echo "MySQL backup failed at $(date) for database $db_database. See $log_directory/errorlog_$current_datetime.txt for details." >> "$log_directory/backuplog_$current_datetime.txt"
fi

# Retention Policy: Keep the last 7 backup files
max_files=7
current_files=$(ls -t "$backup_directory" | wc -l)

if [ "$current_files" -gt "$max_files" ]; then
    # Sort files by modification time and delete the oldest ones
    ls -t "$backup_directory" | tail -n +"$((max_files + 1))" | xargs -I {} rm "$backup_directory"{}
fi

