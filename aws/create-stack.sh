#!/usr/bin/env bash

set -euo pipefail

source ./common-function.sh

create-stack() {
  set-parameter $1
  if [[ -n "$parameters" ]]; then
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
    if [[ -n "$is_completed" ]]; then
      echo $result
      break
    else
      is_error=$(echo $result | grep "does not exist" || [[ $? == 1 ]])
      if [[ -n "$is_error" ]]; then
        echo "${type} creating error"
        exit 1
      else
      echo "${type} creating..."
      sleep 5
      fi
    fi
  done
done