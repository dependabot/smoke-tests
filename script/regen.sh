#!/bin/bash

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPENDABOT=$(command -v dependabot || echo "$REPO_ROOT/dependabot")
if [ ! -x "$DEPENDABOT" ]; then
  echo "Dependabot CLI not found. Install it with: go install github.com/dependabot/cli/cmd/dependabot@latest"
  exit 1
fi

# In sandboxed environments with TLS interception (e.g. Codespaces),
# pass the mkcert CA to the proxy so it can verify MITM certs.
# Requires script/setup-tls.sh to have been run first.
PROXY_CERT_ARGS=()
MKCERT_CA="/home/runner/work/_temp/runtime-logs/mkcert/rootCA.pem"
if [ -f "$MKCERT_CA" ]; then
  PROXY_CERT_ARGS=(--proxy-cert "$MKCERT_CA")
fi

usage() {
  echo "Regenerate smoke test files"
  echo ""
  echo "Usage: $0 [options] <file> [<file>, ...]"
  echo ""
  echo "Options:"
  echo "  --updater-image <image>  Use a pre-built updater Docker image"
  echo "  --local-core <path>      Path to a local dependabot-core checkout to build from"
  echo "  --core-pr <number>       dependabot-core PR number to checkout and build from"
  echo ""
  echo "Examples:"
  echo "  $0 tests/smoke-bundler.yaml"
  echo "  $0 --updater-image my-image:latest tests/smoke-bundler.yaml"
  echo "  $0 --local-core ../dependabot-core tests/smoke-python-pip.yaml"
  echo "  $0 --core-pr 12345 tests/smoke-python-pip.yaml tests/smoke-python-pip-compile.yaml"
  exit "${1:-1}"
}

UPDATER_IMAGE=""
LOCAL_CORE=""
CORE_PR=""
FILES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --updater-image)
      if [[ -z "${2:-}" || "$2" == -* ]]; then
        echo "Error: --updater-image requires a non-empty argument."
        usage
      fi
      UPDATER_IMAGE="$2"
      shift 2
      ;;
    --local-core)
      if [[ -z "${2:-}" || "$2" == -* ]]; then
        echo "Error: --local-core requires a non-empty argument."
        usage
      fi
      LOCAL_CORE="$2"
      shift 2
      ;;
    --core-pr)
      if [[ -z "${2:-}" || "$2" == -* ]]; then
        echo "Error: --core-pr requires a non-empty argument."
        usage
      fi
      CORE_PR="$2"
      shift 2
      ;;
    -h|--help)
      usage 0
      ;;
    *)
      FILES+=("$1")
      shift
      ;;
  esac
done

if [ ${#FILES[@]} -eq 0 ]; then
  usage
fi

# Validate mutually exclusive options
if [ -n "$LOCAL_CORE" ] && [ -n "$CORE_PR" ]; then
  echo "Error: Provide only one of --local-core or --core-pr, not both."
  exit 1
fi

if [ -n "$UPDATER_IMAGE" ] && { [ -n "$LOCAL_CORE" ] || [ -n "$CORE_PR" ]; }; then
  echo "Error: Cannot combine --updater-image with --local-core or --core-pr."
  exit 1
fi

# Build updater image from dependabot-core if requested
CLEANUP_DIR=""
cleanup() {
  if [ -n "$CLEANUP_DIR" ] && [ -d "$CLEANUP_DIR" ]; then
    echo "Cleaning up temporary directory..."
    rm -rf "$CLEANUP_DIR"
  fi
}
trap cleanup EXIT

if [ -n "$LOCAL_CORE" ] || [ -n "$CORE_PR" ]; then
  # Determine the package-manager from the first test file
  PKG_MGR=$(grep 'package-manager:' "${FILES[0]}" | head -1 | awk '{print $2}')
  if [ -z "$PKG_MGR" ]; then
    echo "Error: Could not determine package-manager from ${FILES[0]}"
    exit 1
  fi

  # Validate all files share the same package-manager
  for f in "${FILES[@]:1}"; do
    OTHER_PKG=$(grep 'package-manager:' "$f" | head -1 | awk '{print $2}')
    if [ "$OTHER_PKG" != "$PKG_MGR" ]; then
      echo "Error: All test files must use the same package-manager when building from core."
      echo "  ${FILES[0]} uses '$PKG_MGR' but $f uses '$OTHER_PKG'."
      exit 1
    fi
  done

  # Map package-manager names to dependabot-core build directory names
  case "$PKG_MGR" in
    pip) BUILD_ECO="python" ;;
    submodules) BUILD_ECO="git_submodules" ;;
    *) BUILD_ECO="$PKG_MGR" ;;
  esac

  CORE_DIR=""
  if [ -n "$LOCAL_CORE" ]; then
    CORE_DIR=$(cd "$LOCAL_CORE" 2>/dev/null && pwd)
    if [ ! -d "$CORE_DIR" ]; then
      echo "Error: Directory '$LOCAL_CORE' does not exist."
      exit 1
    fi
    if [ ! -f "$CORE_DIR/script/build" ]; then
      echo "Error: '$LOCAL_CORE' does not look like a dependabot-core checkout (missing script/build)."
      exit 1
    fi
  else
    CORE_DIR=$(mktemp -d)
    CLEANUP_DIR="$CORE_DIR"
    echo "Cloning dependabot-core and checking out PR #${CORE_PR}..."
    if ! git clone --depth=1 --recurse-submodules https://github.com/dependabot/dependabot-core.git "$CORE_DIR"; then
      echo "Error: Failed to clone dependabot-core."
      exit 1
    fi
    cd "$CORE_DIR"
    if ! gh pr checkout "$CORE_PR" --repo dependabot/dependabot-core --detach --recurse-submodules; then
      echo "Error: Failed to checkout PR #${CORE_PR}."
      cd "$REPO_ROOT"
      exit 1
    fi
    cd "$REPO_ROOT"
  fi

  echo "Building updater image for ecosystem: $BUILD_ECO (package-manager: $PKG_MGR)"

  # Snapshot existing updater images so we can detect the newly built one
  BEFORE_IMAGES=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep 'dependabot-updater-' | grep ':latest$' | sort)

  cd "$CORE_DIR"
  if ! script/build "$BUILD_ECO"; then
    echo "Error: Failed to build updater image for '$BUILD_ECO'."
    cd "$REPO_ROOT"
    exit 1
  fi
  cd "$REPO_ROOT"

  AFTER_IMAGES=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep 'dependabot-updater-' | grep ':latest$' | sort)
  UPDATER_IMAGE=$(comm -13 <(echo "$BEFORE_IMAGES") <(echo "$AFTER_IMAGES") | head -1)

  # If no new image appeared, the build may have replaced an existing one —
  # fall back to the most recently created updater image.
  if [ -z "$UPDATER_IMAGE" ]; then
    UPDATER_IMAGE=$(docker images --format '{{.Repository}}:{{.Tag}} {{.CreatedAt}}' \
      | grep 'dependabot-updater-' | grep ':latest ' | sort -k2 -r | head -1 | awk '{print $1}')
  fi

  if [ -z "$UPDATER_IMAGE" ]; then
    echo "Error: No updater image found after building '$BUILD_ECO'."
    exit 1
  fi
  echo "Built image: $UPDATER_IMAGE"
fi

UPDATER_IMAGE_ARG=()
if [ -n "$UPDATER_IMAGE" ]; then
  UPDATER_IMAGE_ARG=(--updater-image="$UPDATER_IMAGE")
fi

for file in "${FILES[@]}"
do
  RESULT_FILE=$(mktemp)

  # Download existing proxy cache and run with --cache=cache, same as the
  # Smoke workflow, so regenerated output matches what cached CI produces.
  rm -rf cache
  SUITE=$(basename "$file" .yaml | sed 's/^smoke-//')
  "$REPO_ROOT/script/download-cache.sh" "$SUITE" 2>/dev/null || true

  "$DEPENDABOT" test -f "$file" -o "$RESULT_FILE" --cache=cache "${PROXY_CERT_ARGS[@]}" "${UPDATER_IMAGE_ARG[@]}"

  if grep -q "^output:" "$RESULT_FILE" 2>/dev/null; then
    cp "$RESULT_FILE" "$file"
  fi
  rm -f "$RESULT_FILE"
done
