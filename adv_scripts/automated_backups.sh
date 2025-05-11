#!/bin/bash
# Backup script for critical files
backup_dir="/backups"
source_dir="/home/ec2-user"
date=$(date +%Y%m%d)

backup_file="$backup_dir/backup_$date.tar.gz"

# Ensure backup directory exists
mkdir -p "$backup_dir"

# Create backup and log outcome
if sudo tar -czf "$backup_file" "$source_dir"; then
	echo "Backup successful: $backup_file"
else
	echo "Backup FAILED on $(date)" >&2
	exit 1
fi

# Delete backups older than 30 days
find "$backup_dir" -type f -name "backup_*.tar.gz" -mtime +30 -exec rm -f {} \;

