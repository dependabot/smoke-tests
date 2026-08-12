module github.com/dependabot/smoke-tests/go/graphs/replace-local

go 1.22

require golang.org/x/text v0.3.7

replace golang.org/x/text => ../nonexistent
