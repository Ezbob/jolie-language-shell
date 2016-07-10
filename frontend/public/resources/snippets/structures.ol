include "console.iol"
include "string_utils.iol"

/* 
 * Jolie data structure example
 */

main {
	// Jolie uses advanced tree-like datastructures to emulate different basic data structures
	
	// You can assign values to variables just like most other languages
	structured = "I'm the head!";

	// Furthermore, you can assign values to nested variables 
	structured.nested = "I'm nested in 'structure'";

	// Variables can also be used as arrays ( 'structured = "I'm the head!";' is the same as 'structured[0] = "I'm the head!";' )
	structured[1] = "next!";

	// The 'with'-construct makes nested assignment easier
	with (structured) {
		.nested2 = "I'm also nested!";
		.array[0] = 42;
		.array[1] = 37;
		with( .moreNested ) {
			.luckyNumber = 23131387
		}
	};

	// You can access the head value:
	println@Console(structured)();
	
	// Nested structures are accessed using the dot operator:
	println@Console(structured.nested)();
	
	// Arrays and nested arrays can be indexed by using square brackets: 
	println@Console(structured.array[1])();

	// You can get a string representation of the whole structure and print it: (useful when debugging!) 
	valueToPrettyString@StringUtils(structured)(pretty);
	println@Console(pretty)()
}
