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

if [ "$2" = "--with-cache" ]
then
  suite=$(echo "$1" | sed -e "s/^tests\/smoke-//" -e "s/\.yaml$//")
  rm -rf cache
  script/download-cache.sh "$suite"
  "$DEPENDABOT" test -f "$1" -o "$1" --cache cache "${PROXY_CERT_ARGS[@]}"
else
  "$DEPENDABOT" test -f "$1" -o "$1" "${PROXY_CERT_ARGS[@]}"
fi
