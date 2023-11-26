#!/bin/bash -e

source ./parameter.sh

types=(${1//,/ })

check-stack-status() {
  for type in ${types[@]}; do
  type=${type:-'invalid'}
    if [ $type = "role" ]; then
      stack_name=$ROLE_STACK_NAME
    elif [ $type = "cognito" ]; then
      stack_name=$COGNITO_STACK_NAME
    elif [ $type = "secrets-manager" ]; then
      stack_name=$SECRETS_MANAGER_STACK_NAME
    elif [ $type = "dynamodb" ]; then
      stack_name=$DYNAMODB_STACK_NAME
    elif [ $type = "open-search-serverless" ]; then
      stack_name=$OPEN_SEARCH_SERVERLESS_STACK_NAME
    elif [ $type = "s3" ]; then
      stack_name=$S3_STACK_NAME
    elif [ $type = "vpc" ]; then
      stack_name=$VPC_STACK_NAME
    elif [ $type = "ec2" ]; then
      stack_name=$EC2_STACK_NAME
    elif [ $type = "ecr" ]; then
      stack_name=$ECR_STACK_NAME
    elif [ $type = "ecs" ]; then
      stack_name=$ECS_STACK_NAME
    elif [ $type = "lambda" ]; then
      stack_name=$LAMBDA_STACK_NAME
    elif [ $type = "lambda-function-url" ]; then
      stack_name=$LAMBDA_FUNCTION_URL_STACK_NAME
    else
      echo "引数にはrole,cognito,secrets-manager,dynamodb,s3,ec2,ecr,ecs,lambda,lambda-function-urlのいずれかを指定してください"
      exit 1
    fi
    set +e
    aws cloudformation describe-stacks --stack-name $stack_name
    set -e
  done
}

if [ "$2" == "watch" ] && [ ${#types[@]} -eq 1 ]; then
  while true; do
    set +e
    result=$(check-stack-status | grep CREATE_COMPLETE)
    set -e
    if [ -n "$result" ]; then
      echo $result
      break
    else
      echo nodata
      sleep 5
    fi
  done
else
  check-stack-status
fi