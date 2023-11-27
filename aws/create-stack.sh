#!/bin/bash

source ./parameter.sh
source ./common-function.sh

create-stack() {
  type=${1:-'invalid'}
  if [ $type = "role" ]; then
    stack_name=$ROLE_STACK_NAME
    template_body="file://role-stack.json"
    parameters="
      ParameterKey=AllowCloudFormationToCreateBaseStackRoleName,ParameterValue=$ALLOW_CLOUD_FORMATION_TO_CREATE_BASE_STACK_ROLE_NAME \
      ParameterKey=AllowCloudFormationToCreateEC2StackRoleName,ParameterValue=$ALLOW_CLOUD_FORMATION_TO_CREATE_EC2_STACK_ROLE_NAME \
      ParameterKey=AllowCloudFormationToCreateECSOrLambdaStackRoleName,ParameterValue=$ALLOW_CLOUD_FORMATION_TO_CREATE_ECS_OR_LAMBDA_STACK_ROLE_NAME"
    role_arn=$CREATE_ROLE_ARN
  elif [ $type = "cognito" ]; then
    stack_name=$COGNITO_STACK_NAME
    template_body="file://cognito-stack.json"
    parameters="
      ParameterKey=UserPoolDomainName,ParameterValue=$USER_POOL_DOMAIN_NAME \
      ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME"
    role_arn=$COGNITO_ROLE_ARN
  elif [ $type = "secrets-manager" ]; then
    cognito_user_pool_id=$(aws cloudformation describe-stacks --stack-name $COGNITO_STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='UserPoolId'].OutputValue" --output text)
    cognito_user_pool_client_id=$(aws cloudformation describe-stacks --stack-name $COGNITO_STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='UserPoolClientId'].OutputValue" --output text)
    cognito_user_pool_client_secret=$(aws cognito-idp describe-user-pool-client --user-pool-id $cognito_user_pool_id --client-id $cognito_user_pool_client_id --region $REGION --query 'UserPoolClient.ClientSecret' --output text)

    stack_name=$SECRETS_MANAGER_STACK_NAME
    template_body="file://secrets-manager-stack.json"
    parameters="
    ParameterKey=NextAuthSecretValue,ParameterValue=$NEXTAUTH_SECRET_VALUE \
    ParameterKey=CognitoClientSecretValue,ParameterValue=$cognito_user_pool_client_secret"
    role_arn=$SECRETS_MANAGER_ROLE_ARN
  elif [ $type = "dynamodb" ]; then
    stack_name=$DYNAMODB_STACK_NAME
    template_body="file://dynamodb-stack.json"
    parameters=""
    role_arn=$DYNAMODB_ROLE_ARN
  elif [ $type = "open-search-serverless" ]; then
    stack_name=$OPEN_SEARCH_SERVERLESS_STACK_NAME
    template_body="file://open-search-serverless-stack.json"
    parameters="
      ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
      ParameterKey=S3StackName,ParameterValue=$S3_STACK_NAME"
    role_arn=$OPEN_SEARCH_SERVERLESS_ROLE_ARN
  elif [ $type = "s3" ]; then
    stack_name=$S3_STACK_NAME
    template_body="file://s3-stack.json"
    parameters="
      ParameterKey=GithubUserName,ParameterValue=$GITHUB_USER_NAME \
      ParameterKey=GithubRepositoryName,ParameterValue=$GITHUB_REPOSITORY_NAME"
    role_arn=$S3_ROLE_ARN
  elif [ $type = "vpc" ]; then
    stack_name=$VPC_STACK_NAME
    template_body="file://vpc-stack.json"
    parameters="
      ParameterKey=LocalIpAddress,ParameterValue=$(curl -s http://checkip.amazonaws.com/)/32"
    role_arn=$VPC_ROLE_ARN
  elif [ $type = "ec2" ]; then
    stack_name=$EC2_STACK_NAME
    template_body="file://ec2-stack.json"
    parameters="
      ParameterKey=S3StackName,ParameterValue=$S3_STACK_NAME \
      ParameterKey=VPCStackName,ParameterValue=$VPC_STACK_NAME \
      ParameterKey=CognitoStackName,ParameterValue=$COGNITO_STACK_NAME \
      ParameterKey=SecretsManagerStackName,ParameterValue=$SECRETS_MANAGER_STACK_NAME \
      ParameterKey=KeyName,ParameterValue=$KEY_NAME \
      ParameterKey=DeployModuleName,ParameterValue=$DEPLOY_MODULE_NAME \
      ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
      ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
      ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME"
    role_arn=$VPC_ROLE_ARN
  elif [ $type = "ecr" ]; then
    stack_name=$ECR_STACK_NAME
    template_body="file://ecr-stack.json"
    parameters="
      ParameterKey=GithubUserName,ParameterValue=$GITHUB_USER_NAME \
      ParameterKey=GithubRepositoryName,ParameterValue=$GITHUB_REPOSITORY_NAME"
    role_arn=$ECR_ROLE_ARN
  elif [ $type = "ecs" ]; then
    stack_name=$ECS_STACK_NAME
    template_body="file://ecs-stack.json"
    parameters="
      ParameterKey=CognitoStackName,ParameterValue=$COGNITO_STACK_NAME \
      ParameterKey=SecretsManagerStackName,ParameterValue=$SECRETS_MANAGER_STACK_NAME \
      ParameterKey=ECRStackName,ParameterValue=$ECR_STACK_NAME \
      ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
      ParameterKey=LocalIpAddress,ParameterValue=$(curl -s http://checkip.amazonaws.com/)/32 \
      ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
      ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME \
      ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME"
    role_arn=$ECS_ROLE_ARN
  elif [ $type = "lambda-with-http-api-gateway" ]; then
    stack_name=$LAMBDA_STACK_NAME
    template_body="file://lambda-with-http-api-gateway-stack.json"
    parameters="
      ParameterKey=CognitoStackName,ParameterValue=$COGNITO_STACK_NAME \
      ParameterKey=ECRStackName,ParameterValue=$ECR_STACK_NAME \
      ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
      ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
      ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME"
    role_arn=$LAMBDA_ROLE_ARN
  elif [ $type = "lambda-with-rest-api-gateway" ]; then
    stack_name=$LAMBDA_STACK_NAME
    template_body="file://lambda-with-rest-api-gateway-stack.json"
    parameters="
      ParameterKey=CognitoStackName,ParameterValue=$COGNITO_STACK_NAME \
      ParameterKey=ECRStackName,ParameterValue=$ECR_STACK_NAME \
      ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
      ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
      ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME"
    role_arn=$LAMBDA_ROLE_ARN
  elif [ $type = "lambda-function-url" ]; then
    stack_name=$LAMBDA_FUNCTION_URL_STACK_NAME
    template_body="file://lambda-function-url-stack.json"
    parameters="
      ParameterKey=CognitoStackName,ParameterValue=$COGNITO_STACK_NAME \
      ParameterKey=ACMCertificateArn,ParameterValue=$ACM_CERTIFICATE_ARN \
      ParameterKey=ECRStackName,ParameterValue=$ECR_STACK_NAME \
      ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
      ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
      ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME"
    role_arn=$LAMBDA_FUNCTION_URL_ROLE_ARN
  else
    echo "引数にはrole,cognito,secrets-manager,dynamodb,open-search-serverless,s3,ec2,ecr,ecs,lambda-with-http-api-gateway,lambda-with-rest-api-gateway,lambda-function-urlのいずれかを指定してください"
    exit 1
  fi

  if [ -n "$parameters" ]; then
      aws cloudformation create-stack \
      --stack-name $stack_name \
      --template-body $template_body \
      --parameters $parameters \
      --capabilities CAPABILITY_NAMED_IAM \
      --role-arn $role_arn \
      --on-failure DELETE \
      --no-retain-except-on-create
  else
      aws cloudformation create-stack \
      --stack-name $stack_name \
      --template-body $template_body \
      --capabilities CAPABILITY_NAMED_IAM \
      --role-arn $role_arn \
      --on-failure DELETE \
      --no-retain-except-on-create
  fi
}

types=(${1//,/ })

for type in ${types[@]}; do
  create-stack $type
  while true; do
    result=$(check-stack-status $type)
    is_completed=$(echo $result | grep CREATE_COMPLETE || [[ $? == 1 ]])
    if [ -n "$is_completed" ]; then
      echo $result
      break
    else
      is_error=$(echo $result | grep "does not exist" || [[ $? == 1 ]])
      if [ -n "$is_error" ]; then
        echo "${type} does not exist"
        exit 1
      else
      echo "${type} creating..."
      sleep 5
      fi
    fi
  done
done