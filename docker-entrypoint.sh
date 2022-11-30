#!/usr/bin/env bash
set -Eeo pipefail

git config --global credential.helper store

lpass login

if [ -n "$ARM_CLIENT_ID" ] && [ -n "$ARM_CLIENT_SECRET" ]; then
  echo -e "\033[32m»»» Logging into Azure\033[0m"
  az login --service-principal -u "$ARM_CLIENT_ID" -p=$ARM_CLIENT_SECRET -t "${ARM_TENANT_ID}" >/dev/null
fi

if [ -n "$ARM_SUBSCRIPTION_ID" ]; then
  echo -e "\033[32m»»» Setting up subscription\033[0m"
  az account set --subscription $ARM_SUBSCRIPTION_ID
fi

eval `ssh-agent`

git config --global user.email "provisioning@netic.dk"
git config --global user.name "Automation User"

exec "$@"
