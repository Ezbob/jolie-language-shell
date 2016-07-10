include "console.iol" // Gives access to the console service

/*
 * Jolie Hello World example
 */

main {
	// Call an operation on another service:
	println@Console( "Hello world!" )()
}

