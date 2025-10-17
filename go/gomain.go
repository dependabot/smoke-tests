package main

// When go tidy runs it checks the import statements in the project
// to see what is actually used. Thus, for sufficient testing we must
// have a main that imports the direct dependencies.
import (
	_ "example.com/elsewhere"
	_ "example.com/local"
	_ "github.com/fatih/color"
	_ "github.com/inconshreveable/mousetrap"
	_ "golang.org/x/crypto/cryptobyte"
	_ "rsc.io/qr"
	_ "rsc.io/quote"
)

func main() {}
