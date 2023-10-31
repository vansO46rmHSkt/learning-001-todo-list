#!/bin/bash -e

source ./parameter.sh

aws cloudformation create-stack \
    --stack-name $BASE_STACK_NAME \
    --template-body file://base-stack.json \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters ParameterKey=UserArnForDeloyS3,ParameterValue=$USER_ARN_FOR_DELOY_S3 ParameterKey=LocalIpAddress,ParameterValue=$(curl -s http://checkip.amazonaws.com/)/32 \
    --role-arn $ROLE_ARN \
    --on-failure DELETE \
    --no-retain-except-on-create
