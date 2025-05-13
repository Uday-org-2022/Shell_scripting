#!/bin/bash
set -e
source "$1"

# Check if KEY_NAME and REGION are set
if [ -z "$KEY_NAME" ] || [ -z "$REGION" ]; then
  echo "KEY_NAME and REGION must be defined in the environment file."
  exit 1
fi

# Check if the key pair already exists
key_exists=$(aws ec2 describe-key-pairs --key-name "$KEY_NAME" --region "$REGION" --query 'KeyPairs[0].KeyName' --output text 2>/dev/null)

if [ "$key_exists" == "$KEY_NAME" ]; then
  echo "Key pair '$KEY_NAME' already exists."
else
  echo "Creating new key pair '$KEY_NAME'..."
  aws ec2 create-key-pair \
    --key-name "$KEY_NAME" \
    --query 'KeyMaterial' \
    --region "$REGION" \
    --output text > "${KEY_NAME}.pem"

  chmod 400 "${KEY_NAME}.pem"
  echo "Key pair '$KEY_NAME' created and saved to ${KEY_NAME}.pem."
fi