include "../evaluator/dockerEvaluatorIFace.iol"
include "console.iol"
include "time.iol"
include "string_utils.iol"
include "jar:file:///home/ezbob/Documents/jolieFun/project/src/jolie/tests/server.jap!/common.iol"

outputPort DockerSandbox {
	Location: "socket://localhost:9000"
	Protocol: sodep
	Interfaces: ContainerConfigIFace
}


outputPort ContainedService {
  Interfaces: ExportedOperationsIFace
}


main
{
    containerName = "test1";
    requestSandbox@DockerSandbox( {
      .containerName = containerName,
      .evaluatorJap = "/home/ezbob/Documents/jolieFun/project/src/jolie/tests/server.jap"
    } )( sandboxResponse );

    valueToPrettyString@StringUtils( sandboxResponse )( pretty );
    println@Console( pretty )();


    getBinding@DockerSandbox( containerName )( bindings );

    valueToPrettyString@StringUtils( bindings )( pretty );

    println@Console( pretty )();
/*
    l = bindings.location;
    p = bindings.protocol;

    trim@StringUtils( l )( triml );
    trim@StringUtils( p )( trimp );

    println@Console( triml )();
    println@Console( trimp )();
*/
    ContainedService.location = bindings.location;
    ContainedService.protocol = bindings.protocol;

    getOutput@DockerSandbox( containerName )( out );
    println@Console( out )();

    hello@ContainedService()();
    hello@ContainedService()();

    getOutput@DockerSandbox( containerName )( out );
    println@Console( out )()

/*
  	send@DockerSandbox({
  		.containerName = "test1",
  		.language = "jolie",
  		.code = "include \"console.iol\"\n main { println@Console( \"hello\" )() }\n"
  	})( response );

  	valueToPrettyString@StringUtils(response)(pretty);
  	println@Console( pretty )();
*/
	//stopSandbox@DockerSandbox( containerName )()
}
