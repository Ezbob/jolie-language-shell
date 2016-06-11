/*include "console.iol"
include "common.iol"
include "file.iol"

execution { concurrent }

inputPort DoIn {
	Location: "socket://localhost:8000/"
	Protocol: sodep
	Interfaces: ExportedOperationsIFace
}

constants {
  TIMEOUT = 2000
}

init
{
  println@Console( "ALIVE" )() // needed to signal that the container is up
}

main
{
	[ hello( void )() {
		println@Console( "Writing little file" )();

	} ]
}
*/

include "runtime.iol"
include "file.iol"
include "common.iol"
include "console.iol"
include "time.iol"

constants {
  TIMEOUT = 2000
}

inputPort LocalInput {
	Location: "local"
	Interfaces: ExportedOperationsIFace
}

inputPort CloudServer {
	Location: "socket://localhost:8000/"
	Protocol: sodep
	Interfaces: ExportedOperationsIFace
}

execution { sequential }

init
{
	println@Console( "ALIVE" )();
  	deleteDir@File( "tmp" )();
  	mkdir@File( "tmp" )()
}

main
{
	[ load( request )( token ) {
		filename = "tmp/" + new;
		filename += ".ol";

		if ( request.short ) {
			println@Console( "hello" )();
			writeFile@File( {
				.content = "include \"console.iol\" \n main { \n " + request.program + " \n } ",
				.filename = filename
			} )();
			println@Console( "write that shite" )()
		} else {
			writeFile@File( {
				.content = request.program,
				.filename = filename
			} )()	
		};

		println@Console( "got here!" )();

		install( RuntimeException =>
		  println@Console( main.RuntimeException.stackTrace )()
		);

		loadEmbeddedService@Runtime( {
		  .type = "jolie",
		  .filepath = filename
		} )( location );

		token = new;
		global.map.(token) = location;

		setNextTimeout@Time( TIMEOUT {
		  .operation = "unload",
		  .message = token
		} )
	} ]

	[ unload( token )() {
		println@Console( "Unloaded" )();
		callExit@Runtime( global.map.(token) )()
	} ]
}
