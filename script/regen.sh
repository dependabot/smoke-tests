#!/bin/bash

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPENDABOT=$(command -v dependabot || echo "$REPO_ROOT/dependabot")
if [ ! -x "$DEPENDABOT" ]; then
  echo "Dependabot CLI not found. Run script/download-cli.sh first."
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

if [ $# -eq 0 ]
  then
    echo "Regenerate multiple test files without a cache"
    echo "Usage: $0 <file> [<file>, ...]"
    exit 1
fi

for file in "$@"
do
  "$DEPENDABOT" test -f "$file" -o "$file" "${PROXY_CERT_ARGS[@]}"
done
