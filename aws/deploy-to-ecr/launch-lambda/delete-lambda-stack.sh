#!/bin/bash -e

source ./parameter.sh

aws cloudformation delete-stack --stack-name $LAMBDA_STACK_NAME --role-arn $ROLE_ARN