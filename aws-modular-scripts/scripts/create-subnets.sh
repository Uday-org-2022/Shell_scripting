#!/bin/bash
set -e

# Validate input
if [ -z "$1" ]; then
  echo "Usage: $0 <env-file>"
  exit 1
fi

# Source environment and state files
source "$1"
STATE_FILE="./state/infra-ids-${ENV_NAME}.env"
source "$STATE_FILE"

# Function to get subnet ID by CIDR
get_subnet_id_by_cidr() {
  local cidr=$1
  aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=cidr-block,Values=$cidr" \
    --region "$REGION" \
    --query 'Subnets[0].SubnetId' --output text
}

# --- Public Subnet ---
PUBLIC_SUBNET_ID=$(get_subnet_id_by_cidr "$PUB_SUB1_CIDR")

if [ "$PUBLIC_SUBNET_ID" == "None" ]; then
  PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "$PUB_SUB1_CIDR" \
    --availability-zone "${REGION}a" \
    --region "$REGION" \
    --query 'Subnet.SubnetId' --output text)

  aws ec2 create-tags \
    --resources "$PUBLIC_SUBNET_ID" \
    --tags Key=Name,Value="${ENV_NAME}-public-subnet-a" \
    --region "$REGION"

  echo "Created public subnet: $PUBLIC_SUBNET_ID"
  # Update state file (remove old lines, append updated ones)
  echo "PUBLIC_SUBNET_ID=$PUBLIC_SUBNET_ID" >> "$STATE_FILE"
else
  echo "Public subnet already exists: $PUBLIC_SUBNET_ID"
fi

# --- Private Subnet ---
PRIVATE_SUBNET_ID=$(get_subnet_id_by_cidr "$PRIV_SUB1_CIDR")

if [ "$PRIVATE_SUBNET_ID" == "None" ]; then
  PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
    --vpc-id "$VPC_ID" \
    --cidr-block "$PRIV_SUB1_CIDR" \
    --availability-zone "${REGION}a" \
    --region "$REGION" \
    --query 'Subnet.SubnetId' --output text)

  aws ec2 create-tags \
    --resources "$PRIVATE_SUBNET_ID" \
    --tags Key=Name,Value="${ENV_NAME}-private-subnet-a" \
    --region "$REGION"

  echo "Created private subnet: $PRIVATE_SUBNET_ID"
  # Update state file (remove old lines, append updated ones)
  echo "PRIVATE_SUBNET_ID=$PRIVATE_SUBNET_ID" >> "$STATE_FILE"
  echo "✅ Subnet creation complete and IDs saved to $STATE_FILE"
else
  echo "Private subnet already exists: $PRIVATE_SUBNET_ID"
fi

