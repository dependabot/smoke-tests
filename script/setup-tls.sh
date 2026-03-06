#!/bin/bash
# Sets up TLS certificates for running Dependabot CLI in sandboxed environments
# (GitHub Codespaces / GitHub Actions with TLS interception).
#
# In these environments, a runc shim intercepts container creation and replaces
# /etc/ssl/certs/ with only a mkcert CA cert. This breaks the Dependabot CLI's
# proxy<->updater trust chain because the proxy's dynamic MITM CA (dbot-ca.crt)
# gets overwritten.
#
# The fix:
# 1. Disable the runc shim's bind mounts (point CERT_PATH to non-existent file)
#    so containers keep their original cert stores
# 2. Pass the mkcert CA to the proxy via --proxy-cert so it can verify the
#    infrastructure's MITM certs on outbound connections
# 3. The CLI's normal update-ca-certificates flow then works: it injects
#    dbot-ca.crt into the updater, and update-ca-certificates adds it to the
#    untouched system cert store

set -e

MKCERT_CA="/home/runner/work/_temp/runtime-logs/mkcert/rootCA.pem"
RUNC_SHIM="/usr/bin/runc"

# Check if we're in a sandboxed environment with TLS interception
if [ ! -f "$MKCERT_CA" ]; then
  echo "No mkcert CA found at $MKCERT_CA - not in a TLS-intercepted environment."
  echo "No setup needed."
  exit 0
fi

if [ ! -f "$RUNC_SHIM" ] || ! head -1 "$RUNC_SHIM" | grep -q "bash"; then
  echo "runc is not a shim script - no TLS fix needed."
  exit 0
fi

echo "Detected TLS-intercepted sandboxed environment."
echo "Disabling runc shim certificate bind mounts..."

# Point the runc shim's CERT_PATH to a non-existent file so it falls through
# to the env-only code path (no bind mounts over /etc/ssl/certs/).
# This preserves the container's original cert store so update-ca-certificates works.
sudo sed -i 's|^CERT_PATH=.*|CERT_PATH="/nonexistent/cert.pem"|' "$RUNC_SHIM"

echo "TLS setup complete."
echo "Use --proxy-cert $MKCERT_CA when running the Dependabot CLI."
echo ""
echo "Example:"
echo "  dependabot test -f tests/smoke-docker.yaml --proxy-cert $MKCERT_CA"
