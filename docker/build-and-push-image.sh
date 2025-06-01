#!/bin/bash

# load credentials and account ID
source config/secrets.env
source config/ecr-repo.env

# build image
docker build -f "docker/Dockerfile" -t playground/flask-app .

# tag image for ECR
docker tag "$NAMESPACE/$REPO:latest" $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/playground/flask-app:latest

# Check if ECR repo exists, create if not

if ! aws ecr describe-repositories --repository-names "$NAMESPACE/$REPO" --region us-east-1 > /dev/null 2>&1; then
  aws ecr create-repository --repository-name "$NAMESPACE/$REPO" --region us-east-1
fi

# push image to ECR
docker push $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$NAMESPACE/$REPO:latest