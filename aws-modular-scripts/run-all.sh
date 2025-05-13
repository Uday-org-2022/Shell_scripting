#!/bin/bash
set -e

ENV=$1
if [[ -z "$ENV" ]]; then
  echo "Usage: ./run-all.sh dev|test"
  exit 1
fi

ENV_FILE="./env/${ENV}.env"
STATE_FILE="./state/infra-ids-${ENV}.env"
> "$STATE_FILE"

for script in scripts/*.sh; do
  echo "Running $script for $ENV environment..."
  bash "$script" "$ENV_FILE"
done
