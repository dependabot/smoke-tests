#!/bin/bash

# This script is useful for regenerating all of the smoke tests running locally.

declare -a arr=("actions" "bundler" "cargo" "composer" "docker" "elm" "go" "go-grouped" "gradle" "hex" "maven" "npm" "nuget" "pip" "pip-compile" "pipenv" "poetry" "pub" "submodules" "terraform")
for eco in "${arr[@]}"
do
  dependabot test -f "tests/smoke-$eco.yaml" -o "tests/smoke-$eco.yaml"
done
