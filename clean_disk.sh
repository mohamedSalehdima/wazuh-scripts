#!/bin/bash

# Get system information
host=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
ram=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }' | sed 's/[ \t]*$//')
disk=$(df -h | awk '$NF=="/"{printf "%s", $5}' | sed 's/%//')
cpu=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}' | sed 's/[ \t]*$//')

# Create JSON output
json='{"host":"'"$host"'", "ram":"'"$ram"'", "cpu":"'"$cpu"'", "disk":"'"$disk"'"}'

# Check if disk usage is above 90%
if [ "$disk" -ge 90 ]; then
    echo "Disk usage is above 90%. Cleaning up old directories..."

    # Find and delete directories older than 3 months in /var/ossec/logs/archives/
    find /var/ossec/logs/archives/2024 -mindepth 1 -maxdepth 1 -type d -mtime +90 -exec rm -rf {} \;

    echo "Cleanup completed."
else
    echo "Disk usage is below 90%. No cleanup required."
fi

# Output system health as JSON
echo "$json"
