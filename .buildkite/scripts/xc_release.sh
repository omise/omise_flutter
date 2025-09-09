#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_WORKSPACE:?GITHUB_WORKSPACE must be set}"
: "${VERSION:?VERSION must be set}"
: "${AWS_S3_BUCKET:?AWS_S3_BUCKET must be set}"
: "${AWS_REGION:?AWS_REGION must be set}"
: "${AWS_DOMAIN:?AWS_DOMAIN must be set}"
: "${WRAPPER_REPO_DIR:?WRAPPER_REPO_DIR must be set}"

# Set workspace
FLUTTER_DIR="$GITHUB_WORKSPACE/omise_flutter_module"
[[ -d "$FLUTTER_DIR" ]] || { echo "❌ Flutter module not found"; exit 1; }
cd "$FLUTTER_DIR"

# Build frameworks
echo "🏗️  Building XCFrameworks…"
FRAMEWORK_DIR="$FLUTTER_DIR/build/ios-framework"
flutter build ios-framework --output="$FRAMEWORK_DIR" --no-debug --no-profile

if [[ -d "$FRAMEWORK_DIR/Release" ]]; then
  XC_DIR="$FRAMEWORK_DIR/Release"
else
  XC_DIR="$FRAMEWORK_DIR"
fi

# Zip frameworks
echo "📂  Zipping frameworks in $XC_DIR"

pushd "$XC_DIR" > /dev/null
shopt -s nullglob
FIXED_TIMESTAMP=202501010000

for fw in *.xcframework; do
  find "$fw" -exec touch -t "$FIXED_TIMESTAMP" {} +
  find "$fw" -type f -exec chmod 644 {} +
  find "$fw" -type d -exec chmod 755 {} +

  echo "📦 Zipping $fw → ${fw}.zip"
  find "$fw" -type f | sort | TZ=UTC zip -q -X -D "${fw}.zip" -@
done
popd > /dev/null

# Compute checksums of each zip
echo "🔢  Computing checksums…"
zip_files=()
checksums=()
for zip in "$XC_DIR"/*.xcframework.zip; do
  zip_files+=("$zip")
  checksum="$(swift package compute-checksum "$zip")"
  checksums+=("$checksum")
done

# Upload to S3
echo "☁️  Uploading XCFrameworks"
for i in "${!zip_files[@]}"; do
  zip_path="${zip_files[$i]}"
  checksum="${checksums[$i]}"
  filename=$(basename "$zip_path")

  aws s3 cp "$zip_path" \
    "s3://${AWS_S3_BUCKET}/sdk/xcframeworks/${VERSION}/$filename" \
    --content-type      application/zip \
    --cache-control     "public, max-age=0, must-revalidate, no-transform" \
    --content-encoding  identity \
    --metadata          sha256="$checksum"
done

# Update SPM
echo "✍️  Updating Package.swift"
TEMPLATE="$GITHUB_WORKSPACE/.buildkite/scripts/Package.swift.template"
OUTPUT="$GITHUB_WORKSPACE/$WRAPPER_REPO_DIR/Package.swift"

library_targets=$(
  for zip in "${zip_files[@]}"; do
    name=$(basename "$zip" .xcframework.zip)
    printf "\"%s\",\n                " "$name"
  done
)

binary_targets=$(
  for i in "${!zip_files[@]}"; do
    name=$(basename "${zip_files[$i]}" .xcframework.zip)
    checksum="${checksums[$i]}"
    url="${AWS_DOMAIN}/sdk/xcframeworks/${VERSION}/${name}.xcframework.zip"
    cat <<-EOF
        .binaryTarget(
            name: "$name",
            url: "$url",
            checksum: "$checksum"
        ),
EOF
  done
)

export library_targets binary_targets
envsubst < "$TEMPLATE" > "$OUTPUT"

# Commit, push tag, release in the wrapper repo
cd "$GITHUB_WORKSPACE/$WRAPPER_REPO_DIR"
git config user.name  "github-actions"
git config user.email "actions@github.com"
git add Package.swift

if ! git diff --cached --quiet; then
  git commit -m "release omise_flutter_spm $VERSION"
  git tag    "$VERSION" -m "$VERSION"
  git push origin HEAD:main
  git push origin "$VERSION"
  echo "✅  Distribution complete — wrapper tagged $VERSION"
  
  echo "🏷️  Creating GitHub Release $VERSION"
  # Requires GH CLI authenticated or GITHUB_TOKEN set
  if command -v gh >/dev/null 2>&1; then
    export GH_TOKEN="$GIT_PAT"
    gh release create "$VERSION" \
      --title "v$VERSION" \
      --notes "Automated release for v$VERSION"
  else
    echo "⚠️  GitHub CLI (gh) not installed; skipping release creation"
  fi
else
  echo "ℹ️  No changes in Package.swift; skipping commit/tag."
fi
