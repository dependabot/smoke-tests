#!/bin/bash
gh release download --repo dependabot/cli -p "*linux-amd64.tar.gz"
tar xzf *.tar.gz
mkdir -p ~/.local/bin
mv dependabot ~/.local/bin
rm *.tar.gz

echo "export LOCAL_GITHUB_ACCESS_TOKEN=$GITHUB_TOKEN" >> ~/.bashrc
