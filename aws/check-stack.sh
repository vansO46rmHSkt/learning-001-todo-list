#!/bin/bash -e

source ./parameter.sh
source ./common-function.sh

types=(${1//,/ })

if [ "$2" == "watch" ]; then
  for type in "${types[@]}"; do
    while true; do
      result=$(check-stack-status $type)
      is_completed=$(echo $result | grep CREATE_COMPLETE || [[ $? == 1 ]])
      if [ -n "$is_completed" ]; then
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
else
  for type in "${types[@]}"; do
    check-stack-status "$type"
  done
fi