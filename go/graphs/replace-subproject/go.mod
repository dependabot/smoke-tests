module github.com/dependabot/smoke-tests/go/graphs/replace-subproject

go 1.22

require github.com/dependabot/smoke-tests/go/graphs/replace-subproject/subpkg v0.0.0

require rsc.io/quote v1.5.0

require (
    golang.org/x/text v0.4.0 // indirect
    rsc.io/sampler v1.3.0 // indirect
)

replace github.com/dependabot/smoke-tests/go/graphs/replace-subproject/subpkg => ./subpkg
