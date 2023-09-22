#!/bin/bash

# This script is useful for regenerating all of the smoke tests running locally.

for f in tests/*.yaml
do
  if [ "$1" = "--with-cache" ]
  then
    suite=$(echo "$f" | sed -e "s/^tests\/smoke-//" -e "s/\.yaml$//")
    rm -rf cache
    source script/download-cache.sh $suite
    dependabot test -f "$f" -o "$f" --cache cache
  else
    dependabot test -f "$f" -o "$f"
  fi
done
