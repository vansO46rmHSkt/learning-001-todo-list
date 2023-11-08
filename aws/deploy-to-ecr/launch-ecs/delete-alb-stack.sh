#!/bin/bash -e

source ./parameter.sh

aws cloudformation delete-stack --stack-name $ALB_STACK_NAME --role-arn $ROLE_ARN