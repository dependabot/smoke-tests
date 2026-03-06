#!/bin/bash

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPENDABOT=$(command -v dependabot || echo "$REPO_ROOT/dependabot")
if [ ! -x "$DEPENDABOT" ]; then
  echo "Dependabot CLI not found. Run script/download-cli.sh first."
  exit 1
fi

if [ $# -eq 0 ]
  then
    echo "Regenerate multiple test files without a cache"
    echo "Usage: $0 <file> [<file>, ...]"
    exit 1
fi

for file in "$@"
do
  "$DEPENDABOT" test -f "$file" -o "$file"
done
