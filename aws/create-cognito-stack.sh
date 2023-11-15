#!/bin/bash -e

source ./parameter.sh

aws cloudformation create-stack \
    --stack-name $COGNITO_STACK_NAME \
    --template-body file://cognito-stack.json \
    --parameters \
        ParameterKey=UserPoolDomainName,ParameterValue=$USER_POOL_DOMAIN_NAME \
    --role-arn $ROLE_ARN \
    --on-failure DELETE \
    --no-retain-except-on-create
