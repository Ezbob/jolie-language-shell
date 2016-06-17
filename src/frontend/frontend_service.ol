include "frontend_service.iol"
include "../javaServices/interfaces/file_extras.iol"
include "../javaServices/interfaces/spark_server.iol"

execution { 
	sequential 
}

inputPort Frontend {
	Location: "socket://localhost:9120"
	Protocol: sodep
	Interfaces: FrontendInterface 
}

main
{
  [ start()() {

  	toAbsolutePath@FileExtras("public")(contentDir);
  	startServer@SimpleSparkServer({
		.publicDirectory = contentDir,
		.url = "/",
		.port = 9100
	})( status )

  }]
  [ stop()() {
  	stopServer@SimpleSparkServer()(status)
  }]
}