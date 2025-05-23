#!/usr/bin/env bash
set -Eeo pipefail

if [ -n "$ARM_CLIENT_ID" ] && [ -n "$ARM_CLIENT_SECRET" ]; then
  echo -e "\033[32m»»» Logging into Azure\033[0m"
  az login --service-principal -u "$ARM_CLIENT_ID" -p="$ARM_CLIENT_SECRET" -t "${ARM_TENANT_ID}" >/dev/null
fi

if [ -n "$ARM_SUBSCRIPTION_ID" ]; then
  echo -e "\033[32m»»» Setting up subscription\033[0m"
  az account set --subscription "$ARM_SUBSCRIPTION_ID"
fi

# shellcheck disable=SC2006,SC2046
eval `ssh-agent`

git config --global user.email "${GIT_AUTHOR_EMAIL:-provisioning@netic.dk}"
git config --global user.name "${GIT_AUTHOR_NAME:-Automation User}"

exec "$@"
