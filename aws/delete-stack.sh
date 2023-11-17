#!/bin/bash -e

source ./parameter.sh

type=${1:-'invalid'}

if [ $type = "role" ]; then
  stack_name=$ROLE_STACK_NAME
  role_arn=$CREATE_ROLE_ARN
elif [ $type = "cognito" ]; then
  stack_name=$COGNITO_STACK_NAME
  role_arn=$COGNITO_ROLE_ARN
elif [ $type = "dynamodb" ]; then
  stack_name=$DYNAMODB_STACK_NAME
  role_arn=$DYNAMODB_ROLE_ARN
elif [ $type = "s3" ]; then
  stack_name=$S3_AND_VPC_STACK_NAME
  role_arn=$S3_ROLE_ARN
elif [ $type = "ec2" ]; then
  stack_name=$EC2_STACK_NAME
  role_arn=$EC2_ROLE_ARN
elif [ $type = "ecr" ]; then
  stack_name=$ECR_STACK_NAME
  role_arn=$ECR_ROLE_ARN
elif [ $type = "ecs" ]; then
  stack_name=$ECS_STACK_NAME
  role_arn=$ECS_ROLE_ARN
elif [ $type = "lambda" ]; then
  stack_name=$LAMBDA_STACK_NAME
  role_arn=$LAMBDA_ROLE_ARN
elif [ $type = "lambda-function-url" ]; then
  stack_name=$LAMBDA_FUNCTION_URL_STACK_NAME
  role_arn=$LAMBDA_FUNCTION_URL_ROLE_ARN
else
  echo "引数にはrole,cognito,dynamodb,s3,ec2,ecr,ecs,lambda,lambda-function-urlのいずれかを指定してください"
  exit 1
fi

aws cloudformation delete-stack --stack-name $stack_name --role-arn $role_arn
