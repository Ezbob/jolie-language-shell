include "../dockerService/docker_jolie.iol"
include "../javaServices/interfaces/file_extras.iol"
include "console.iol"
include "time.iol"
include "string_utils.iol"
include "jar:file:///home/ezbob/Documents/jolieFun/project/src/jolie/tests/server/server.jap!/include/common.iol"

outputPort DockerSandbox {
    Location: "socket://localhost:9000"
    Protocol: sodep
    Interfaces: ContainerConfigIFace
}

outputPort ContainedService {
    Interfaces: ExportedOperationsIFace
    Protocol: sodep
}

main
{
    containerName = "test1";
    japPath = "server/server.jap";

    toAbsolutePath@FileExtras( japPath )( japAbsPath );

    requestSandbox@DockerSandbox( {
      .containerName = containerName,
      .evaluatorJap = japAbsPath
    } )( sandboxResponse );

    valueToPrettyString@StringUtils( sandboxResponse )( pretty );
    println@Console( pretty )();

    getLocation@DockerSandbox( containerName )( location );

    valueToPrettyString@StringUtils( bindings )( pretty );

    println@Console( pretty )();

    ContainedService.location = location;

    hello@ContainedService()();
    hello@ContainedService()();

    getLastOutput@DockerSandbox( containerName )( out );
    println@Console( out )()

    //stopSandbox@DockerSandbox( containerName )()
}
