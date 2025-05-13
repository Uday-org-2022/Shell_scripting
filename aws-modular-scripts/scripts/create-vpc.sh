#!/bin/bash
set -e

# Ensure environment file is provided as the first argument
if [ -z "$1" ]; then
  echo "Error: Environment file is required as the first argument."
  exit 1
fi

# Source the environment variables from the provided file
source "$1"

# Ensure essential environment variables are set
if [ -z "$VPC_CIDR" ]; then
  echo "Error: VPC_CIDR is not set in the environment file."
  exit 1
fi

if [ -z "$REGION" ]; then
  echo "Error: REGION is not set in the environment file."
  exit 1
fi

# Default tag name if not provided in the environment file
TAG_NAME="${TAG_NAME:-${ENV_NAME}-vpc}"

STATE_FILE="./state/infra-ids-${ENV_NAME}.env"

# Check if the VPC already exists based on CIDR block
EXISTING_VPC=$(aws ec2 describe-vpcs \
  --cidr-block "$VPC_CIDR" \
  --region "$REGION" \
  --query 'Vpcs[0].VpcId' --output text)

if [ "$EXISTING_VPC" != "None" ]; then
  echo "VPC already exists with CIDR block $VPC_CIDR: $EXISTING_VPC"
  VPC_ID="$EXISTING_VPC"
else
  # Create a new VPC
  VPC_ID=$(aws ec2 create-vpc \
    --cidr-block "$VPC_CIDR" \
    --region "$REGION" \
    --query 'Vpc.VpcId' --output text)

  echo "Created VPC with ID: $VPC_ID"
  # Tag the VPC with custom tag name
  aws ec2 create-tags \
  --resources "$VPC_ID" \
  --tags Key=Name,Value="$TAG_NAME" \
  --region "$REGION"

  # Save VPC ID to the state file
  echo "VPC_ID=$VPC_ID" >> "$STATE_FILE"
  echo "VPC setup complete. VPC ID is $VPC_ID, Tag Name: $TAG_NAME"
fi

