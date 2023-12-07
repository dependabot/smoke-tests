#!/bin/bash
if [ $# -eq 0 ]
  then
    echo "First argument is the ecosystem cache name, e.g. bundler"
    exit 1
fi
retry=0
until [ "$retry" -ge 5 ]
do
  gh run download --repo dependabot/smoke-tests --name cache-"$1" --dir cache
  if [ $? -eq 0 ]; then
    exit 0
  fi
  retry=$((retry+1))
  sleep 1
done

echo "Failed to download cache"
exit 1
