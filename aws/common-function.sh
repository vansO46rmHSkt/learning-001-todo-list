check-stack-status() {
  type=${1:-'invalid'}
  stack_name=""

  case $type in
    "role")
      stack_name=$ROLE_STACK_NAME
      ;;
    "cognito")
      stack_name=$COGNITO_STACK_NAME
      ;;
    "secrets-manager")
      stack_name=$SECRETS_MANAGER_STACK_NAME
      ;;
    "dynamodb")
      stack_name=$DYNAMODB_STACK_NAME
      ;;
    "open-search-serverless")
      stack_name=$OPEN_SEARCH_SERVERLESS_STACK_NAME
      ;;
    "s3")
      stack_name=$S3_STACK_NAME
      ;;
    "vpc")
      stack_name=$VPC_STACK_NAME
      ;;
    "ec2")
      stack_name=$EC2_STACK_NAME
      ;;
    "ecr")
      stack_name=$ECR_STACK_NAME
      ;;
    "ecs")
      stack_name=$ECS_STACK_NAME
      ;;
    "lambda-with-http-api-gateway")
      stack_name=$LAMBDA_STACK_NAME
      ;;
    "lambda-with-rest-api-gateway")
      stack_name=$LAMBDA_STACK_NAME
      ;;
    "lambda-function-url")
      stack_name=$LAMBDA_FUNCTION_URL_STACK_NAME
      ;;
    *)
      if [[ $type =~ ^arn:aws:cloudformation:.* ]]; then
        stack_name=$type
      else 
        echo "引数にはrole,cognito,secrets-manager,dynamodb,open-search-serverless,s3,ec2,ecr,ecs,lambda-with-http-api-gateway,lambda-with-rest-api-gateway,lambda-function-urlのいずれかを指定してください"
        exit 1
      fi
      ;;
  esac

  aws cloudformation describe-stacks --stack-name $stack_name 2>&1 || true
}
