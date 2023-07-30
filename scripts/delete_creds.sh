#!/bin/bash

# Set the region
export AWS_DEFAULT_REGION="us-east-1"

# Set the secret name and value
AWS_SECRET_NAME="aws-credentials"
DB_SECRET_NAME="db-credentials"
REDIS_SECRET_NAME="redis-credentials"

# Delete the secret
aws secretsmanager delete-secret --secret-id "$AWS_SECRET_NAME" --force-delete-without-recovery
aws secretsmanager delete-secret --secret-id "$DB_SECRET_NAME" --force-delete-without-recovery
aws secretsmanager delete-secret --secret-id "$REDIS_SECRET_NAME" --force-delete-without-recovery