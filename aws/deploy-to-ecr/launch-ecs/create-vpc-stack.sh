#!/bin/bash -e

source ./parameter.sh

aws cloudformation create-stack \
    --stack-name $VPC_STACK_NAME \
    --template-body file://vpc-stack.json \
    --parameters \
        ParameterKey=LocalIpAddress,ParameterValue=$(curl -s http://checkip.amazonaws.com/)/32 \
    --role-arn $ROLE_ARN \
    --on-failure DELETE \
    --no-retain-except-on-create
