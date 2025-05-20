# load credentials and account ID
source ../secrets.env
source ../ecr-repo.env

# build image
docker build .. -t playground/flask-app

# tag image for ECR
docker tag $NAMESPACE/$REPO:latest $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/playground/flask-app:latest

# push image to ECR
docker push $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/$NAMESPACE/$REPO:latest