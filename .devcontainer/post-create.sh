#!/bin/bash
go install github.com/dependabot/cli/cmd/dependabot@latest

echo "export LOCAL_GITHUB_ACCESS_TOKEN=$GITHUB_TOKEN" >> ~/.bashrc
