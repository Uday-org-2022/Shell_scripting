#!/bin/bash

# Alert when disk space is low

threshold=90  # Set your threshold value
partition="/"  # Partition to check

# Get current usage for the specified partition
current_usage=$(df "$partition" | awk 'NR==2 {gsub("%",""); print $5}')

# Check if current usage is greater than the threshold
if [ "$current_usage" -gt "$threshold" ]; then
  echo "Disk usage is ${current_usage}% on ${partition}" | mail -s "Disk Space Alert on $(hostname)" admin@example.com
else
  echo "Disk usage is normal: ${current_usage}%"
fi
