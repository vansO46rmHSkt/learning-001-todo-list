#!/bin/bash -e

source ./parameter.sh

aws cloudformation create-stack \
    --stack-name $DYNAMODB_STACK_NAME \
    --template-body file://dynamodb-stack.json \
    --capabilities CAPABILITY_NAMED_IAM \
    --role-arn $ROLE_ARN \
    --on-failure DELETE \
    --no-retain-except-on-create
