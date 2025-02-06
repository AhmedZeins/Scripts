#!/bin/bash

# Function to configure AWS CLI
configure_aws() {
    echo "Enter AWS Access Key ID:"
    read AWS_ACCESS_KEY_ID

    echo "Enter AWS Secret Access Key:"
    read -s AWS_SECRET_ACCESS_KEY  # -s hides input for security

    echo "Enter AWS Region (default: us-east-1):"
    read AWS_REGION
    AWS_REGION=${AWS_REGION:-us-east-1}  # Default to us-east-1 if empty

    # Configure AWS CLI
    aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
    aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
    aws configure set region "$AWS_REGION"

    # Test the configuration
    echo "Verifying AWS credentials..."
    if aws sts get-caller-identity >/dev/null 2>&1; then
        echo "AWS credentials configured successfully!"
    else
        echo "Error: Invalid AWS credentials. Please try again."
    fi
}

# Run the function
configure_aws
