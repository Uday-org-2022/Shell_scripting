#!/bin/bash
# Bulk user creation from CSV file

tail -n +2 users.csv | while IFS=, read -r username fullname; do
  if id "$username" &>/dev/null; then
    echo "User $username already exists, skipping..."
    continue
  fi
  useradd -m -c "$fullname" "$username"
  echo "$username:default123" | chpasswd
  chage -d 0 "$username"
  echo "Created user: $username"
done

