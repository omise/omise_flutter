#!/usr/bin/env bash
set -euo pipefail

# Check if envsubst is already available
if command -v envsubst >/dev/null 2>&1; then
  echo "✅ envsubst already installed at: $(command -v envsubst)"
  exit 0
fi

echo "📦 Installing GNU gettext (for envsubst)…"

# Create a temporary directory for installation
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download GNU gettext source tarball
GETTEXT_VERSION="0.26"
TARBALL="gettext-${GETTEXT_VERSION}.tar.gz"
URL="https://ftp.gnu.org/gnu/gettext/${TARBALL}"

echo "⬇️  Downloading gettext ${GETTEXT_VERSION} from ${URL}"
curl -LO "$URL"

echo "📂 Extracting gettext..."
tar -xzf "$TARBALL"
cd "gettext-${GETTEXT_VERSION}"

echo "⚙️  Configuring build..."
./configure --disable-dependency-tracking --disable-silent-rules --disable-debug --without-emacs --without-java --without-csharp

echo "🔨 Building..."
make -j"$(sysctl -n hw.ncpu)"

echo "📥 Installing (requires write access to /usr/local)…"
sudo make install

# Verify installation
if command -v envsubst >/dev/null 2>&1; then
  echo "✅ envsubst installed successfully at: $(command -v envsubst)"
else
  echo "❌ Installation completed but envsubst not found in PATH"
  exit 1
fi

# Clean up
cd /
rm -rf "$TMP_DIR"
