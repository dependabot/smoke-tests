#!/bin/bash
gh release download --repo dependabot/cli -p "*linux-amd64.tar.gz"
tar xzvf *.tar.gz >/dev/null 2>&1
mv dependabot /usr/local/bin
