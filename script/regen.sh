#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "Regenerate multiple test files without a cache"
    echo "Usage: $0 <file> [<file>, ...]"
    exit 1
fi

for file in "$@"
do
  dependabot test -f "$file" -o "$file"
done
