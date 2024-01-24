#!/bin/bash

# This script is useful for regenerating one of the smoke tests running locally.

if [ "$2" = "--with-cache" ]
then
  suite=$(echo "$1" | sed -e "s/^tests\/smoke-//" -e "s/\.yaml$//")
  rm -rf cache
  script/download-cache.sh "$suite"
  dependabot test -f "$1" -o "$1" --cache cache
else
  dependabot test -f "$1" -o "$1"
fi
