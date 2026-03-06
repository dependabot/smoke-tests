#!/bin/bash
# Downloads the latest Dependabot CLI binary to the repo root.
# Requires the GitHub CLI (gh) to be installed and authenticated.
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Detect platform
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

PATTERN="*${OS}-${ARCH}.tar.gz"
echo "Downloading latest Dependabot CLI for ${OS}-${ARCH}..."
if ! gh release download --repo dependabot/cli -p "$PATTERN" --clobber; then
  echo "Failed to download Dependabot CLI. Check that gh is authenticated."
  exit 1
fi
tar xzf ./*"${OS}-${ARCH}.tar.gz"
rm -f ./*"${OS}-${ARCH}.tar.gz"
if [ ! -x ./dependabot ]; then
  echo "Failed to extract Dependabot CLI binary."
  exit 1
fi
echo "Downloaded $(./dependabot --version)"
