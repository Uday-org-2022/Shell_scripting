#!/bin/bash
set -e

# Load environment and state files
source "$1"
STATE_FILE="./state/infra-ids-${ENV_NAME}.env"

if [ ! -f "$STATE_FILE" ]; then
  echo "State file not found: $STATE_FILE"
  exit 1
fi

source "$STATE_FILE"

# Validate required variables
REQUIRED_VARS=("VPC_ID" "AMI_ID" "INSTANCE_TYPE" "KEY_NAME" "SG_ID" "PUBLIC_SUBNET_ID" "PRIVATE_SUBNET_ID" "REGION")
for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Error: $var is not set."
    exit 1
  fi
done

# Check if VPC exists
echo "Checking if VPC '$VPC_ID' exists in region '$REGION'..."
if ! aws ec2 describe-vpcs --vpc-ids "$VPC_ID" --region "$REGION" >/dev/null 2>&1; then
  echo "VPC '$VPC_ID' does not exist. Exiting."
  exit 1
fi
echo "VPC exists. Continuing with EC2 launches..."

# Launch Public EC2 Instance
echo "Launching Public EC2 instance..."
PUBLIC_INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --count 1 \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SG_ID" \
  --subnet-id "$PUBLIC_SUBNET_ID" \
  --associate-public-ip-address \
  --region "$REGION" \
  --user-data file://install-nginx.sh \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Public Instance launched: $PUBLIC_INSTANCE_ID"

# Launch Private EC2 Instance (no public IP)
echo "Launching Private EC2 instance..."
PRIVATE_INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --count 1 \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SG_ID" \
  --subnet-id "$PRIVATE_SUBNET_ID" \
  --associate-public-ip-address false \
  --region "$REGION" \
  --user-data file://install-nginx.sh \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Private Instance launched: $PRIVATE_INSTANCE_ID"

# Save to state file
echo "PUBLIC_INSTANCE_ID=${PUBLIC_INSTANCE_ID}" >> "$STATE_FILE"
echo "PRIVATE_INSTANCE_ID=${PRIVATE_INSTANCE_ID}" >> "$STATE_FILE"