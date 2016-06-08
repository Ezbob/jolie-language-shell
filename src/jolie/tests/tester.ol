include "../dockerService/docker_jolie.iol"
include "../javaServices/interfaces/file_extras.iol"
include "console.iol"
include "time.iol"
include "file.iol"
include "string_utils.iol"
include "../share/shared.iol"

outputPort DockerSandbox {
    Location: "socket://localhost:9000"
    Protocol: sodep
    Interfaces: ContainerConfigIFace
}

outputPort ContainedService {
    Interfaces: ExportedOperationsIFace
    Protocol: sodep
}

main {

    containerName = "test1";
    japPath = "../share/server/server.jap";

    toAbsolutePath@FileExtras( japPath )( japAbsPath );

    requestSandbox@DockerSandbox( {
      .containerName = containerName,
      .evaluatorJap = japAbsPath,
      .exposedPort = 8000
    } )( sandboxResponse );

    valueToPrettyString@StringUtils( sandboxResponse )( pretty );
    println@Console( pretty )();

    getLocation@DockerSandbox( containerName )( location );

    valueToPrettyString@StringUtils( bindings )( pretty );

    println@Console( pretty )();

    ContainedService.location = location;

    toAbsolutePath@FileExtras( "run.ol" )( fullPath );

    readFile@File({
      .filename = fullPath
    })( content );

    load@ContainedService( {
      .program = content,
      .short = false
    } )();
    

    getLastLogEntry@DockerSandbox( containerName )( out );
    println@Console( out )()

    //stopSandbox@DockerSandbox( containerName )()
}
