#!/bin/bash
# Create a single user with input validation and if-else logic

# Read user details
read -p "Enter username: " username
read -p "Enter full name: " fullname
read -sp "Enter password: " password
echo

# Check for empty inputs
if [ -z "$username" ] || [ -z "$fullname" ] || [ -z "$password" ]; then
  echo "❌  Error: All fields (username, full name, and password) must be provided."
  exit 1
fi

# Validate username format (must start with a letter, contain only lowercase letters, digits, underscores or dashes)
if ! [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
  echo "❌  Error: Invalid username format. Must start with a lowercase letter or underscore and contain only lowercase letters, digits, underscores, or dashes."
  exit 2
fi

# Check if user already exists
if id "$username" &>/dev/null; then
  echo "⚠️  User '$username' already exists. Skipping creation."
  exit 3
else
  # Create user and set password
  if sudo useradd -m -c "$fullname" "$username"; then
    echo "$username:$password" | sudo chpasswd
    sudo chage -d 0 "$username"
    echo "✅  User '$username' created successfully. Password must be changed on first login."
    exit 0
  else
    echo "❌  Error: Failed to create user '$username'."
    exit 4
  fi
fi
