module github.com/dependabot/smoke-tests/go/graphs/replace-remote

go 1.22

require golang.org/x/crypto v0.23.0

replace golang.org/x/crypto => github.com/pion/dtls/v2 v2.2.11
