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
	Location: "socket://localhost:8005/"
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
			writeFile@File( {
				.content = "include \"console.iol\" \n main { \n " + request.program + " \n } ",
				.filename = filename
			} )()
		} else {
			writeFile@File( {
				.content = request.program,
				.filename = filename
			} )()	
		};

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
		callExit@Runtime( global.map.(token) )()
	} ]
}
