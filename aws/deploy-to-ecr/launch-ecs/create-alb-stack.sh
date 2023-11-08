#!/bin/bash -e

source ./parameter.sh

aws cloudformation create-stack \
    --stack-name $ALB_STACK_NAME \
    --template-body file://alb-stack.json \
    --parameters \
        ParameterKey=VPCStackName,ParameterValue=$VPC_STACK_NAME \
        ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
        ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME \
    --role-arn $ROLE_ARN \
    --on-failure DELETE \
    --no-retain-except-on-create
