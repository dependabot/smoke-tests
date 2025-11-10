module github.com/dependabot/vgotest

go 1.24.5

require (
	example.com/elsewhere v0.0.0
	example.com/local v0.0.0
	github.com/fatih/color v1.17.0
	github.com/inconshreveable/mousetrap v0.0.0-20141017200713-76626ae9c91c
	golang.org/x/crypto v0.0.0-20180617042118-027cca12c2d6
	rsc.io/qr v0.1.0
	rsc.io/quote v1.4.0
)

require (
	github.com/mattn/go-colorable v0.1.13 // indirect
	github.com/mattn/go-isatty v0.0.20 // indirect
	golang.org/x/sys v0.37.0 // indirect
	golang.org/x/text v0.3.7 // indirect
	rsc.io/sampler v1.0.0 // indirect
)

replace rsc.io/qr => github.com/rsc/qr v0.2.0

replace example.com/local => ./local

replace example.com/elsewhere => ../../elsewhere
