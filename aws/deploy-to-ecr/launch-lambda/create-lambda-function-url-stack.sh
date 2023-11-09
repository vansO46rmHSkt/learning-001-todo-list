#!/bin/bash -e

source ./parameter.sh

aws cloudformation create-stack \
    --stack-name $LAMBDA_FUNCTION_URL_STACK_NAME \
    --template-body file://lambda-function-url-stack.json \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters \
        ParameterKey=BaseStackName,ParameterValue=$BASE_STACK_NAME \
    --role-arn $ROLE_ARN \
    --on-failure DELETE \
    --no-retain-except-on-create
