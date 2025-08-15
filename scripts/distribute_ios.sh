#!/usr/bin/env bash
set -euo pipefail

export GITHUB_WORKSPACE="$(pwd)"
source scripts/setup_env.sh

echo "🔍 Extracting version from pubspec.yaml…"
VERSION=$(grep '^version:' pubspec.yaml | head -1 | sed 's/version: *//')
export VERSION
echo "📌 Using version: ${VERSION}"

source scripts/install_flutter.sh

echo "🚀 Flutter version information:"
flutter --version

if [[ -d "${WRAPPER_REPO_DIR}" ]]; then
  echo "ℹ️  Removing existing ${WRAPPER_REPO_DIR} directory…"
  rm -rf "${WRAPPER_REPO_DIR}"
fi

echo "🐙 Cloning Swift‑PM wrapper repository…"
git clone "https://x-access-token:${GIT_PAT}@github.com/${WRAPPER_REPO}.git" "${WRAPPER_REPO_DIR}"

echo "🏗️  Building and distributing XCFrameworks…"
bash scripts/xc_release.sh

echo "🎉 Distribution complete"
