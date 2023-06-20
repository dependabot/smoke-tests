#!/bin/bash

# This script is useful for regenerating all of the smoke tests running locally.

declare -a arr=("actions" "bundler" "cargo" "composer" "docker" "elm" "go" "go-group-rules" "gradle" "hex" "maven" "npm" "npm-group-rules" "nuget" "pip" "pip-compile" "pipenv" "poetry" "pub" "submodules" "terraform" "yarn" "yarn-berry" "yarn-berry-group-rules" "yarn-berry-workspaces" "yarn-berry-workspaces-group-rules" "yarn-group-rules")
for eco in "${arr[@]}"
do
  dependabot test -f "tests/smoke-$eco.yaml" -o "tests/smoke-$eco.yaml"
done
