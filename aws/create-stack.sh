#!/bin/bash -e

source ./parameter.sh

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
  parameters="ParameterKey=UserPoolDomainName,ParameterValue=$USER_POOL_DOMAIN_NAME"
  role_arn=$COGNITO_ROLE_ARN
elif [ $type = "dynamodb" ]; then
  stack_name=$DYNAMODB_STACK_NAME
  template_body="file://dynamodb-stack.json"
  parameters=""
  role_arn=$DYNAMODB_ROLE_ARN
elif [ $type = "s3" ]; then
  stack_name=$S3_AND_VPC_STACK_NAME
  template_body="file://s3-and-vpc-stack.json"
  parameters="
    ParameterKey=GithubUserName,ParameterValue=$GITHUB_USER_NAME \
    ParameterKey=GithubRepositoryName,ParameterValue=$GITHUB_REPOSITORY_NAME \
    ParameterKey=LocalIpAddress,ParameterValue=$(curl -s http://checkip.amazonaws.com/)/32"
  role_arn=$S3_ROLE_ARN
elif [ $type = "ec2" ]; then
  stack_name=$EC2_STACK_NAME
  template_body="file://ec2-stack.json"
  parameters="
    ParameterKey=S3AndVpcStackName,ParameterValue=$S3_AND_VPC_STACK_NAME \
    ParameterKey=KeyName,ParameterValue=$KEY_NAME \
    ParameterKey=DeployModuleName,ParameterValue=$DEPLOY_MODULE_NAME \
    ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
    ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
    ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME"
  role_arn=$EC2_ROLE_ARN
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
    ParameterKey=ECRStackName,ParameterValue=$ECR_STACK_NAME \
    ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
    ParameterKey=LocalIpAddress,ParameterValue=$(curl -s http://checkip.amazonaws.com/)/32 \
    ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
    ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME \
    ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME"
  role_arn=$ECS_ROLE_ARN
elif [ $type = "lambda" ]; then
  stack_name=$LAMBDA_STACK_NAME
  template_body="file://lambda-stack.json"
  parameters="
    ParameterKey=ECRStackName,ParameterValue=$ECR_STACK_NAME \
    ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME"
  role_arn=$LAMBDA_ROLE_ARN
elif [ $type = "lambda-function-url" ]; then
  stack_name=$LAMBDA_FUNCTION_URL_STACK_NAME
  template_body="file://lambda-function-url-stack.json"
  parameters="
    ParameterKey=ECRStackName,ParameterValue=$ECR_STACK_NAME \
    ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME"
  role_arn=$LAMBDA_FUNCTION_URL_ROLE_ARN
else
  echo "引数にはrole,cognito,dynamodb,s3,ec2,ecr,ecs,lambda,lambda-function-urlのいずれかを指定してください"
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
