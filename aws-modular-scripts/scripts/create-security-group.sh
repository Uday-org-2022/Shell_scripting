#!/bin/bash
set -e

# Check if environment file is provided
if [ -z "$1" ]; then
  echo "Error: Environment file is required as the first argument."
  exit 1
fi

# Load environment variables
source "$1"
STATE_FILE="./state/infra-ids-${ENV_NAME}.env"
source "$STATE_FILE"

# Check if the Security Group already exists
SG_ID=$(aws ec2 describe-security-groups \
  --filters Name=group-name,Values="${ENV_NAME}-sg" \
  --region "$REGION" \
  --query 'SecurityGroups[0].GroupId' --output text)

if [ "$SG_ID" == "None" ]; then
  # Create Security Group if it doesn't exist
  SG_ID=$(aws ec2 create-security-group \
    --group-name "${ENV_NAME}-sg" \
    --description "SG for ${ENV_NAME}" \
    --vpc-id "$VPC_ID" \
    --region "$REGION" \
    --query 'GroupId' --output text)

  echo "Created Security Group with ID: $SG_ID"
  # Add port 22 rule (SSH)
  aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0 \
    --region "$REGION"

  # Add port 80 rule with VPC CIDR
  aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" \
    --protocol tcp \
    --port 80 \
    --cidr "$VPC_CIDR" \
    --region "$REGION"

  # Save the Security Group ID to the state file
  echo "SG_ID=\"$SG_ID\"" >> "$STATE_FILE"

  echo "Security Group setup complete for ENV: $ENV_NAME"
else
  echo "Security Group already exists with ID: $SG_ID"
fi
