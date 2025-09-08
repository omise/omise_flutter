#!/usr/bin/env bash

set -euo pipefail

LOCAL_ENV_FILE=".buildkite/scripts/env.local.sh"
if [[ -f "${LOCAL_ENV_FILE}" ]]; then
  echo "🔧 Loading local environment overrides from ${LOCAL_ENV_FILE}"
  # shellcheck disable=SC1090
  source "${LOCAL_ENV_FILE}"
fi

export WRAPPER_REPO_DIR="${WRAPPER_REPO_DIR:-wrapper_repo}"

required_vars=(
  AWS_S3_BUCKET
  AWS_REGION
  AWS_DOMAIN
  GIT_PAT
  WRAPPER_REPO
  AWS_ROLE_ARN
)

for var in "${required_vars[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "❌ Environment variable ${var} is not set.  Please set it in your Buildkite configuration or env.local.sh."
    exit 1
  fi
done

echo "🧾 Environment configured!"
