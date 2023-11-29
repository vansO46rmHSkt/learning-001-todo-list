#!/bin/bash -e

source ./common-function.sh

delete-stack() {
  set-parameter $1
  aws cloudformation delete-stack --stack-name $stack_name --role-arn $role_arn
}

types=(${1//,/ })

for type in ${types[@]}; do
  delete-stack $type
  while true; do
    result=$(check-stack-status $type)
    is_deleting=$(echo $result | grep DELETE_IN_PROGRESS || [[ $? == 1 ]])
    if [ -z "$is_deleting" ]; then
      is_deleted=$(echo $result | grep "does not exist" || [[ $? == 1 ]])
      if [ -n "$is_deleted" ]; then
        echo "${type} is deleted"
      else
        echo "${type} deletion failed"
      fi
      break
    else
      echo "${type} deleting..."
      sleep 5
    fi
  done
done