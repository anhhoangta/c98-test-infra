#!/bin/bash

# Set the region
AWS_SECRET_NAME="aws-credentials"
AWS_SECRET_VALUE=$(printf '{"AWS_ACCESS_KEY_ID":"%s","AWS_SECRET_ACCESS_KEY":"%s"}' "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY")

# Check if the aws secret exists. If not create the secret.
# Check AWS_SECRET_NAME is set, exit if not set.
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY are not set. Exiting..."
    exit 1
fi

aws secretsmanager describe-secret --secret-id "$AWS_SECRET_NAME" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "The secret $AWS_SECRET_NAME already exists."
else
    echo "The secret $AWS_SECRET_NAME does not exist. Creating the secret..."
    aws secretsmanager create-secret --name "$AWS_SECRET_NAME" --secret-string "$AWS_SECRET_VALUE"
fi 

# Create s3 bucket to store terraform state. Check if the bucket exists. If not create the bucket.
# Check TF_STATE_BUCKET is set, exit if not set.
if [ -z "$TF_STATE_BUCKET" ]; then
    echo "TF_STATE_BUCKET is not set. Exiting..."
    exit 1
fi
aws s3api head-bucket --bucket "$TF_STATE_BUCKET" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "The bucket $TF_STATE_BUCKET already exists."
else
    echo "The bucket $TF_STATE_BUCKET does not exist. Creating the bucket..."
    # If the region is us-east-1, then don't specify the location constraint.
    if [ "$AWS_DEFAULT_REGION" == "us-east-1" ]; then
        aws s3api create-bucket --bucket "$TF_STATE_BUCKET" --region "$AWS_DEFAULT_REGION"
    else
        aws s3api create-bucket --bucket "$TF_STATE_BUCKET" --region "$AWS_DEFAULT_REGION" --create-bucket-configuration LocationConstraint="$AWS_DEFAULT_REGION"
    fi
fi

# Set the secret name and value
DB_SECRET_NAME="db-credentials"
DB_SECRET_VALUE=$(printf '{"db_host":"%s","db_port":"%s","db_name":"%s","db_username":"%s","db_password":"%s"}' "$DB_HOST" "$DB_PORT" "$DB_NAME" "$DB_USER" "$DB_PASSWORD")

REDIS_SECRET_NAME="redis-credentials"
REDIS_SECRET_VALUE=$(printf '{"redis_host":"%s","redis_port":"%s"}' "$REDIS_HOST" "$REDIS_PORT")

aws secretsmanager describe-secret --secret-id "$DB_SECRET_NAME" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "The secret $DB_SECRET_NAME already exists. Updating the secret..."
    echo "$DB_SECRET_VALUE"
    aws secretsmanager update-secret --secret-id "$DB_SECRET_NAME" --secret-string "$DB_SECRET_VALUE"
else
    echo "The secret $DB_SECRET_NAME does not exist. Creating the secret..."
    aws secretsmanager create-secret --name "$DB_SECRET_NAME" --secret-string "$DB_SECRET_VALUE"
fi

# If REDIS_HOST and REDIS_PORT are not set, then continue without creating the redis secret.
if [ -z "$REDIS_HOST" ] || [ -z "$REDIS_PORT" ]; then
    echo "REDIS_HOST and REDIS_PORT are not set. Skipping the creation of the redis secret."
    exit 0
fi

echo "REDIS_HOST and REDIS_PORT are set. Creating the redis secret."
# Check if the redis secret exists. If not create the secret.
aws secretsmanager describe-secret --secret-id "$REDIS_SECRET_NAME" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "The secret $REDIS_SECRET_NAME already exists."
else
    echo "The secret $REDIS_SECRET_NAME does not exist. Creating the secret..."
    aws secretsmanager create-secret --name "$REDIS_SECRET_NAME" --secret-string "$REDIS_SECRET_VALUE"
fi

echo "The secrets have been created successfully."
