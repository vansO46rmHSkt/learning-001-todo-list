#!/bin/bash -e

source ./parameter.sh

aws cloudformation create-stack \
    --stack-name $BASE_STACK_NAME \
    --template-body file://base-stack.json \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters \
        ParameterKey=GithubUserName,ParameterValue=$GITHUB_USER_NAME \
        ParameterKey=GithubRepositoryName,ParameterValue=$GITHUB_REPOSITORY_NAME \
        ParameterKey=LocalIpAddress,ParameterValue=$(curl -s http://checkip.amazonaws.com/)/32 \
    --role-arn $ROLE_ARN \
    --on-failure DELETE \
    --no-retain-except-on-create
