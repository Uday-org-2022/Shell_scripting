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

# Check if a NAT Gateway already exists for the VPC
NAT_GW_ID=$(aws ec2 describe-nat-gateways \
  --filter "Name=subnet-id,Values=$PUBLIC_SUBNET_ID" \
  --region "$REGION" \
  --query 'NatGateways[0].NatGatewayId' \
  --output text)

if [ "$NAT_GW_ID" != "None" ]; then
  # If NAT Gateway exists, print and skip creation
  echo "NAT Gateway already exists: $NAT_GW_ID"
else
  # Allocate Elastic IP
  EIP_ALLOC_ID=$(aws ec2 allocate-address \
    --domain vpc \
    --region "$REGION" \
    --query 'AllocationId' --output text)

  if [ "$EIP_ALLOC_ID" == "None" ]; then
    echo "Error: Failed to allocate Elastic IP."
    exit 1
  fi

  echo "Elastic IP allocated with ID: $EIP_ALLOC_ID"

  # Create NAT Gateway
  NAT_GW_ID=$(aws ec2 create-nat-gateway \
    --subnet-id "$PUBLIC_SUBNET_ID" \
    --allocation-id "$EIP_ALLOC_ID" \
    --region "$REGION" \
    --query 'NatGateway.NatGatewayId' --output text)

  if [ "$NAT_GW_ID" == "None" ]; then
    echo "Error: Failed to create NAT Gateway."
    exit 1
  fi

  echo "Creating NAT Gateway with ID: $NAT_GW_ID"

  # Wait for NAT Gateway to become available
  aws ec2 wait nat-gateway-available \
    --nat-gateway-ids "$NAT_GW_ID" \
    --region "$REGION"

  if [ $? -ne 0 ]; then
    echo "Error: Failed to wait for NAT Gateway to become available."
    exit 1
  fi

  echo "NAT Gateway is now available: $NAT_GW_ID"
  # Write both EIP_ALLOC_ID and NAT_GW_ID to the state file
  {
    echo "EIP_ALLOC_ID=\"$EIP_ALLOC_ID\""
    echo "NAT_GW_ID=\"$NAT_GW_ID\""
  } >> "$STATE_FILE"

  echo "NAT Gateway setup complete for ENV: $ENV_NAME"
fi

