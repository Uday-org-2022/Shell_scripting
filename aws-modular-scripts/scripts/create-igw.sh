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

# Check if state file exists
if [ ! -f "$STATE_FILE" ]; then
  echo "Error: State file $STATE_FILE does not exist. Run VPC script first."
  exit 1
fi
source "$STATE_FILE"

# Check if REGION and VPC_ID are set
if [ -z "$REGION" ]; then
  echo "Error: REGION not set in environment file."
  exit 1
fi

if [ -z "$VPC_ID" ]; then
  echo "Error: VPC_ID not found in environment file."
  exit 1
fi

# Check if IGW_ID exists by filtering VPC_ID
IGW_ID=$(aws ec2 describe-internet-gateways \
  --region "$REGION" \
  --filters Name=attachment.vpc-id,Values="$VPC_ID" \
  --query 'InternetGateways[0].InternetGatewayId' \
  --output text)

# If IGW_ID is found, print it; else, create one
if [ "$IGW_ID" != "None" ]; then
  echo "Internet Gateway already exists: $IGW_ID"
else
  # Create IGW if not found
  IGW_ID=$(aws ec2 create-internet-gateway \
    --region "$REGION" \
    --query 'InternetGateway.InternetGatewayId' --output text)

  echo "Created Internet Gateway: $IGW_ID"

  # Attach IGW to VPC
  aws ec2 attach-internet-gateway \
    --internet-gateway-id "$IGW_ID" \
    --vpc-id "$VPC_ID" \
    --region "$REGION"

  echo "Attached IGW $IGW_ID to VPC $VPC_ID"
  
  # Save IGW_ID to state file
  echo "IGW_ID=$IGW_ID" >> "$STATE_FILE"

  echo "IGW setup complete for ENV: $ENV_NAME"
fi

