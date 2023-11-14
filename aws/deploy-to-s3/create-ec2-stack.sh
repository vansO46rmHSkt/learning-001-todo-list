#!/bin/bash -e

source ./parameter.sh

aws cloudformation create-stack \
    --stack-name $EC2_STACK_NAME \
    --template-body file://ec2-stack.json \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters \
        ParameterKey=BaseStackName,ParameterValue=$BASE_STACK_NAME \
        ParameterKey=KeyName,ParameterValue=$KEY_NAME \
        ParameterKey=DeployModuleName,ParameterValue=$DEPLOY_MODULE_NAME \
        ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
    --role-arn $ROLE_ARN \
    --on-failure DELETE \
    --no-retain-except-on-create
