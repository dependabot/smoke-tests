#!/bin/bash

# This script is useful for regenerating all of the smoke tests running locally.

for f in tests/*.yaml
do
  dependabot test -f "$f" -o "$f"
done
