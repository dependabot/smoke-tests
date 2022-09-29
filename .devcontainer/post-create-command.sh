#!/bin/bash
set -e

# This script is executed per-Codespace.
#
# Anything that should not be shared between debugger sessions should happen here.

# Download CLI
gh release download --repo dependabot/cli-releases -p "*linux-amd64.tar.gz"
tar xzvf ./*.tar.gz >/dev/null 2>&1
rm ./*.tar.gz
mv dependabot /usr/local/bin
