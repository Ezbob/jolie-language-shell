include "console.iol"
include "time.iol"
include "../javaServices/interfaces/file_extras.iol"
include "../javaServices/interfaces/spark_server.iol"

main {

	println@Console( "Starting server" )();

	toAbsolutePath@FileExtras( "../frontend" )( contentDir );

	println@Console( "Serving from" + contentDir )();

	startServer@SimpleSparkServer({
		.publicDirectory = contentDir,
		.url = "/",
		.port = 9100
	})( status );
	println@Console( status )();

	sleep@Time(60000)(something);

	stopServer@SimpleSparkServer()(status);
	println@Console( status )()

}


