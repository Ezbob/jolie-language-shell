include "runtime.iol"
include "file.iol"
include "common.iol"
include "console.iol"
include "time.iol"
include "exec.iol"
include "json_utils.iol"

constants {
    TIMEOUT = 2000
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
	[ eval( request )( output ) {
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

		exec@Exec( "jolie" {
			.args[0] = filename,
      		.waitFor = 1,
			.stdOutConsoleEnable = false
		})( fun );

		if (is_defined(fun.stderr)) {
			output = "There is an error in your code."
		} else {
			output = string ( fun )
		};
		delete@File(filename)()
	} ]
}
