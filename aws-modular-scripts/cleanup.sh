#!/bin/bash
set -e

# Usage check
if [ -z "$1" ]; then
  echo "Usage: $0 <env-file>"
  exit 1
fi

# Load environment and state variables
ENV_FILE="$1"
source "$ENV_FILE"
STATE_FILE="./state/infra-ids-${ENV_NAME}.env"

if [ ! -f "$STATE_FILE" ]; then
  echo "Error: State file not found: $STATE_FILE"
  exit 1
fi

source "$STATE_FILE"

# Ensure REGION is set
if [ -z "$REGION" ]; then
  echo "Error: REGION is not set in env file."
  exit 1
fi

# Helper function to delete resource if ID exists
delete_resource() {
  local resource_id=$1
  local resource_type=$2
  local delete_command=$3

  if [ -n "$resource_id" ]; then
    echo "Deleting $resource_type: $resource_id"
    eval "$delete_command"
  else
    echo "$resource_type ID not found, skipping..."
  fi
}

# --- Delete EC2 Instances ---
if [ -n "$EC2_PUBLIC_ID" ]; then
  echo "Terminating EC2 Public Instance: $EC2_PUBLIC_ID"
  aws ec2 terminate-instances --instance-ids "$EC2_PUBLIC_ID" --region "$REGION"
fi

if [ -n "$EC2_PRIVATE_ID" ]; then
  echo "Terminating EC2 Private Instance: $EC2_PRIVATE_ID"
  aws ec2 terminate-instances --instance-ids "$EC2_PRIVATE_ID" --region "$REGION"
fi

# Wait for EC2 to terminate
echo "Waiting for EC2 instances to terminate..."
aws ec2 wait instance-terminated --instance-ids $EC2_PUBLIC_ID $EC2_PRIVATE_ID --region "$REGION"

# --- Delete NAT Gateway ---
delete_resource "$NAT_GW_ID" "NAT Gateway" \
  "aws ec2 delete-nat-gateway --nat-gateway-id $NAT_GW_ID --region $REGION"

# --- Delete Route Tables (custom only, not main) ---
if [ -n "$PUBLIC_RT_ID" ]; then
  delete_resource "$PUBLIC_RT_ID" "Public Route Table" \
    "aws ec2 delete-route-table --route-table-id $PUBLIC_RT_ID --region $REGION"
fi

if [ -n "$PRIVATE_RT_ID" ]; then
  delete_resource "$PRIVATE_RT_ID" "Private Route Table" \
    "aws ec2 delete-route-table --route-table-id $PRIVATE_RT_ID --region $REGION"
fi

# --- Detach and Delete IGW ---
if [ -n "$IGW_ID" ] && [ -n "$VPC_ID" ]; then
  echo "Detaching and deleting Internet Gateway: $IGW_ID"
  aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --region "$REGION"
  aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID" --region "$REGION"
fi

# --- Delete Subnets ---
delete_resource "$PUBLIC_SUBNET_ID" "Public Subnet" \
  "aws ec2 delete-subnet --subnet-id $PUBLIC_SUBNET_ID --region $REGION"

delete_resource "$PRIVATE_SUBNET_ID" "Private Subnet" \
  "aws ec2 delete-subnet --subnet-id $PRIVATE_SUBNET_ID --region $REGION"

# --- Delete Security Groups ---
delete_resource "$PUBLIC_SG_ID" "Public Security Group" \
  "aws ec2 delete-security-group --group-id $PUBLIC_SG_ID --region $REGION"

delete_resource "$PRIVATE_SG_ID" "Private Security Group" \
  "aws ec2 delete-security-group --group-id $PRIVATE_SG_ID --region $REGION"

# --- Delete Key Pair ---
delete_resource "$KEY_PAIR_NAME" "Key Pair" \
  "aws ec2 delete-key-pair --key-name $KEY_PAIR_NAME --region $REGION"

# --- Delete VPC ---
delete_resource "$VPC_ID" "VPC" \
  "aws ec2 delete-vpc --vpc-id $VPC_ID --region $REGION"

# Optionally, delete state file
echo "Cleaning up state file: $STATE_FILE"
rm -f "$STATE_FILE"

echo "✅ Cleanup complete for environment: $ENV_NAME"