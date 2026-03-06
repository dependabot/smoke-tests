#!/bin/bash

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPENDABOT=$(command -v dependabot || echo "$REPO_ROOT/dependabot")
if [ ! -x "$DEPENDABOT" ]; then
  echo "Dependabot CLI not found. Run script/download-cli.sh first."
  exit 1
fi

if [ "$2" = "--with-cache" ]
then
  suite=$(echo "$1" | sed -e "s/^tests\/smoke-//" -e "s/\.yaml$//")
  rm -rf cache
  script/download-cache.sh "$suite"
  "$DEPENDABOT" test -f "$1" -o "$1" --cache cache
else
  "$DEPENDABOT" test -f "$1" -o "$1"
fi
