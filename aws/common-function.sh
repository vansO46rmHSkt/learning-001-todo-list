source ./parameter.sh

all_types=("role"  "cognito-user-pool" "cognito-id-pool""secrets-manager" "dynamodb" "open-search-serverless" "s3" "vpc" "ec2" "ecr" "ecs" "lambda-with-http-api-gateway" "lambda-with-rest-api-gateway" "lambda-function-url")

set-parameter() {
  type=${1:-'invalid'}
  case $type in
    "role")
      stack_name=$ROLE_STACK_NAME
      template_body="file://role-stack.json"
      parameters="
        ParameterKey=AllowCloudFormationToCreateBaseStackRoleName,ParameterValue=$ALLOW_CLOUD_FORMATION_TO_CREATE_BASE_STACK_ROLE_NAME \
        ParameterKey=AllowCloudFormationToCreateEC2StackRoleName,ParameterValue=$ALLOW_CLOUD_FORMATION_TO_CREATE_EC2_STACK_ROLE_NAME \
        ParameterKey=AllowCloudFormationToCreateECSOrLambdaStackRoleName,ParameterValue=$ALLOW_CLOUD_FORMATION_TO_CREATE_ECS_OR_LAMBDA_STACK_ROLE_NAME"
      role_arn=$CREATE_ROLE_ARN
      ;;
    "cognito-user-pool")
      stack_name=$COGNITO_USER_POOL_STACK_NAME
      template_body="file://cognito-user-pool-stack.json"
      parameters="
        ParameterKey=UserPoolDomainName,ParameterValue=$USER_POOL_DOMAIN_NAME \
        ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME"
      role_arn=$COGNITO_USER_POOL_ROLE_ARN
      ;;
    "cognito-id-pool")
      stack_name=$COGNITO_ID_POOL_STACK_NAME
      template_body="file://cognito-id-pool-stack.json"
      parameters="
        ParameterKey=CognitoUserPoolStackName,ParameterValue=$COGNITO_USER_POOL_STACK_NAME"
      role_arn=$COGNITO_ID_POOL_ROLE_ARN
      ;;
    "secrets-manager")
      cognito_user_pool_id=$(aws cloudformation describe-stacks --stack-name $COGNITO_USER_POOL_STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='UserPoolId'].OutputValue" --output text)
      cognito_user_pool_client_id=$(aws cloudformation describe-stacks --stack-name $COGNITO_USER_POOL_STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='UserPoolClientId'].OutputValue" --output text)
      cognito_user_pool_client_secret=$(aws cognito-idp describe-user-pool-client --user-pool-id $cognito_user_pool_id --client-id $cognito_user_pool_client_id --region $REGION --query 'UserPoolClient.ClientSecret' --output text)

      stack_name=$SECRETS_MANAGER_STACK_NAME
      template_body="file://secrets-manager-stack.json"
      parameters="
      ParameterKey=NextAuthSecretValue,ParameterValue=$NEXTAUTH_SECRET_VALUE \
      ParameterKey=CognitoClientSecretValue,ParameterValue=$cognito_user_pool_client_secret"
      role_arn=$SECRETS_MANAGER_ROLE_ARN
      ;;
    "dynamodb")
      stack_name=$DYNAMODB_STACK_NAME
      template_body="file://dynamodb-stack.json"
      parameters=""
      role_arn=$DYNAMODB_ROLE_ARN
      ;;
    "open-search-serverless")
      stack_name=$OPEN_SEARCH_SERVERLESS_STACK_NAME
      template_body="file://open-search-serverless-stack.json"
      parameters="
        ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
        ParameterKey=S3StackName,ParameterValue=$S3_STACK_NAME"
      role_arn=$OPEN_SEARCH_SERVERLESS_ROLE_ARN
      ;;
    "s3")
      stack_name=$S3_STACK_NAME
      template_body="file://s3-stack.json"
      parameters="
        ParameterKey=GithubUserName,ParameterValue=$GITHUB_USER_NAME \
        ParameterKey=GithubRepositoryName,ParameterValue=$GITHUB_REPOSITORY_NAME"
      role_arn=$S3_ROLE_ARN
      ;;
    "vpc")
      stack_name=$VPC_STACK_NAME
      template_body="file://vpc-stack.json"
      parameters="
        ParameterKey=LocalIpAddress,ParameterValue=$(curl -s http://checkip.amazonaws.com/)/32"
      role_arn=$VPC_ROLE_ARN
      ;;
    "ec2")
      stack_name=$EC2_STACK_NAME
      template_body="file://ec2-stack.json"
      parameters="
        ParameterKey=S3StackName,ParameterValue=$S3_STACK_NAME \
        ParameterKey=VPCStackName,ParameterValue=$VPC_STACK_NAME \
        ParameterKey=CognitoUserPoolStackName,ParameterValue=$COGNITO_USER_POOL_STACK_NAME \
        ParameterKey=SecretsManagerStackName,ParameterValue=$SECRETS_MANAGER_STACK_NAME \
        ParameterKey=KeyName,ParameterValue=$KEY_NAME \
        ParameterKey=DeployModuleName,ParameterValue=$DEPLOY_MODULE_NAME \
        ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
        ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
        ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME"
      role_arn=$VPC_ROLE_ARN
      ;;
    "ecr")
      stack_name=$ECR_STACK_NAME
      template_body="file://ecr-stack.json"
      parameters="
        ParameterKey=GithubUserName,ParameterValue=$GITHUB_USER_NAME \
        ParameterKey=GithubRepositoryName,ParameterValue=$GITHUB_REPOSITORY_NAME"
      role_arn=$ECR_ROLE_ARN
      ;;
    "ecs")
      stack_name=$ECS_STACK_NAME
      template_body="file://ecs-stack.json"
      parameters="
        ParameterKey=CognitoUserPoolStackName,ParameterValue=$COGNITO_USER_POOL_STACK_NAME \
        ParameterKey=SecretsManagerStackName,ParameterValue=$SECRETS_MANAGER_STACK_NAME \
        ParameterKey=ECRStackName,ParameterValue=$ECR_STACK_NAME \
        ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
        ParameterKey=LocalIpAddress,ParameterValue=$(curl -s http://checkip.amazonaws.com/)/32 \
        ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
        ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME \
        ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME"
      role_arn=$ECS_ROLE_ARN
      ;;
    "lambda-with-http-api-gateway")
      stack_name=$LAMBDA_STACK_NAME
      template_body="file://lambda-with-http-api-gateway-stack.json"
      parameters="
        ParameterKey=CognitoUserPoolStackName,ParameterValue=$COGNITO_USER_POOL_STACK_NAME \
        ParameterKey=ECRStackName,ParameterValue=$ECR_STACK_NAME \
        ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
        ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
        ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME"
      role_arn=$LAMBDA_ROLE_ARN
      ;;
    "lambda-with-rest-api-gateway")
      stack_name=$LAMBDA_STACK_NAME
      template_body="file://lambda-with-rest-api-gateway-stack.json"
      parameters="
        ParameterKey=CognitoUserPoolStackName,ParameterValue=$COGNITO_USER_POOL_STACK_NAME \
        ParameterKey=ECRStackName,ParameterValue=$ECR_STACK_NAME \
        ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
        ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
        ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME"
      role_arn=$LAMBDA_ROLE_ARN
      ;;
    "lambda-function-url")
      stack_name=$LAMBDA_FUNCTION_URL_STACK_NAME
      template_body="file://lambda-function-url-stack.json"
      parameters="
        ParameterKey=CognitoUserPoolStackName,ParameterValue=$COGNITO_USER_POOL_STACK_NAME \
        ParameterKey=ACMCertificateArn,ParameterValue=$ACM_CERTIFICATE_ARN \
        ParameterKey=ECRStackName,ParameterValue=$ECR_STACK_NAME \
        ParameterKey=DynamoDBStackName,ParameterValue=$DYNAMODB_STACK_NAME \
        ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
        ParameterKey=HostedZoneName,ParameterValue=$HOSTED_ZONE_NAME"
      role_arn=$LAMBDA_FUNCTION_URL_ROLE_ARN
      ;;
    *)
      if [[ $type =~ ^arn:aws:cloudformation:.* ]]; then
        stack_name=$type
      else 
        echo "引数には$(IFS=, ; echo "${all_types[*]}")のいずれかを指定してください"
        exit 1
      fi
      ;;
  esac
}

check-stack-status() {
  set-parameter $1
  aws cloudformation describe-stacks --stack-name $stack_name 2>&1 || true
}
