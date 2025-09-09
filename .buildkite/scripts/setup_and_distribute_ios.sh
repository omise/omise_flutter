#!/usr/bin/env bash
set -euo pipefail

export GITHUB_WORKSPACE="$(pwd)"
source .buildkite/scripts/setup_env.sh

echo "🔍 Extracting version from pubspec.yaml…"
VERSION=$(grep '^version:' pubspec.yaml | head -1 | sed 's/version: *//')
export VERSION
echo "📌 Using version: ${VERSION}"

echo "🚀 Flutter version information:"
flutter --version

if [[ -d "${WRAPPER_REPO_DIR}" ]]; then
  echo "ℹ️  Removing existing ${WRAPPER_REPO_DIR} directory…"
  rm -rf "${WRAPPER_REPO_DIR}"
fi

echo "🐙 Cloning Swift‑PM wrapper repository…"
# Set up a temporary git credentials file to avoid exposing the token in process lists
GIT_CREDENTIALS_FILE=$(mktemp)
echo "https://x-access-token:${GIT_PAT}@github.com" > "$GIT_CREDENTIALS_FILE"
git config --global credential.helper "store --file=$GIT_CREDENTIALS_FILE"
git clone "https://github.com/${WRAPPER_REPO}.git" "${WRAPPER_REPO_DIR}"
# Clean up credentials after clone
git config --global --unset credential.helper
rm -f "$GIT_CREDENTIALS_FILE"

echo "🏗️  Building and distributing XCFrameworks…"
bash .buildkite/scripts/xc_release.sh

echo "🎉 Distribution complete"
