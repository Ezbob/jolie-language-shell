include "dockerEvaluatorIFace.iol"
include "console.iol"
include "string_utils.iol"

outputPort DockerSandbox {
	Location: "socket://localhost:9000"
	Protocol: sodep
	Interfaces: ContainerConfigIFace
}

main
{
	containerName = "test1";
  	requestSandbox@DockerSandbox( {
  		.containerName = containerName,
  		.evaluatorFile = "/home/ezbob/Documents/jolieFun/server.ol"
  	} )( sandboxResponse );
  	
  	println@Console( sandboxResponse )();
  	println@Console( sandboxResponse.containerName )();

/*
  	send@DockerSandbox({
  		.containerName = "test1",
  		.language = "jolie",
  		.code = "include \"console.iol\"\n main { println@Console( \"hello\" )() }\n"
  	})( response );

  	valueToPrettyString@StringUtils(response)(pretty);
  	println@Console( pretty )();
*/
	stopSandbox@DockerSandbox( containerName )()
}
