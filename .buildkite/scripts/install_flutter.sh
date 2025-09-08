#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.27.2}"
FLUTTER_SDK_DIR="${HOME}/flutter_sdk_${FLUTTER_VERSION}"

if [[ ! -d "${FLUTTER_SDK_DIR}" ]]; then
  echo "📦 Installing Flutter ${FLUTTER_VERSION}…"
  ARCHIVE_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_${FLUTTER_VERSION}-stable.zip"
  curl -L -o flutter.zip "${ARCHIVE_URL}"
  unzip -q flutter.zip -d "${HOME}"
  mv "${HOME}/flutter" "${FLUTTER_SDK_DIR}"
  rm -f flutter.zip
else
  echo "✅ Flutter ${FLUTTER_VERSION} already installed at ${FLUTTER_SDK_DIR}"
fi

export PATH="${FLUTTER_SDK_DIR}/bin:${PATH}"

flutter precache --ios
