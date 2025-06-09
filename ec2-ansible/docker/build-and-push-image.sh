#!/bin/bash

# load credentials and account ID
source config/secrets.env
source config/ecr-repo.env

# Check if ECR repo exists, create if not
if ! aws ecr describe-repositories --repository-names "$NAMESPACE/$REPO" --region us-east-1 > /dev/null 2>&1; then
  aws ecr create-repository --repository-name "$NAMESPACE/$REPO" --region us-east-1
fi

# Set up new builder
docker buildx create --use || true

# Build, tag and push image to ECR
docker buildx build --platform linux/amd64 \
  -f "ec2-ansible/docker/Dockerfile" \
  -t $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$NAMESPACE/$REPO:latest \
  --push .