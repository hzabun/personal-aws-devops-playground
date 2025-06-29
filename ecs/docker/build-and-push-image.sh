#!/bin/bash

# load credentials and account ID
source config/secrets.env
source config/ecr-repo.env

# login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Check if ECR repo exists, create if not
if ! aws ecr describe-repositories --repository-names "$NAMESPACE/$REPO" --region us-east-1 >/dev/null 2>&1; then
  aws ecr create-repository --repository-name "$NAMESPACE/$REPO" --region us-east-1
fi

# Set up new builder only if it doesn't exist
if ! docker buildx inspect mybuilder &>/dev/null; then
  docker buildx create --name mybuilder --use
else
  docker buildx use mybuilder
fi

# Build, tag and push image to ECR
docker buildx build --platform linux/amd64 \
  -f "ecs/docker/Dockerfile" \
  -t $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$NAMESPACE/$REPO:latest \
  --push .
