#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Checking for GitHub CLI (gh)…"

if command -v gh >/dev/null 2>&1; then
  echo "✅ GitHub CLI already installed: $(gh --version | head -n1)"
else
  echo "⚠️ GitHub CLI not found — installing..."

  ARCH=$(uname -m)

  # Download latest .pkg from GitHub
  curl -fsSL "https://github.com/cli/cli/releases/latest/download/gh_${ARCH}.pkg" -o /tmp/gh.pkg

  # Install .pkg (requires sudo privileges)
  sudo installer -pkg /tmp/gh.pkg -target /

  rm /tmp/gh.pkg

  echo "✅ GitHub CLI installed: $(gh --version | head -n1)"
fi
