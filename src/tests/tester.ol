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
      .exposedPort = 8005
    } )( sandboxResponse );

    valueToPrettyString@StringUtils( sandboxResponse )( pretty );
    println@Console( pretty )();

    getLocation@DockerSandbox( containerName )( location );

    valueToPrettyString@StringUtils( bindings )( pretty );

    println@Console( pretty )();

    ContainedService.location = "socket://" + location + ":" + location.ports[0];

    toAbsolutePath@FileExtras( "run.ol" )( fullPath );
/*
    readFile@File({
      .filename = fullPath
    })( content );
*/

    program = "include \"console.iol\"

main
{
  println@Console( \"Run this pleaze!\" )()
}";

    load@ContainedService( {
      .program = program,
      .short = false
    } )();
    

    getLastLogEntry@DockerSandbox( containerName )( out );
    println@Console( out )();

    stopSandbox@DockerSandbox( containerName )();
    shutdown@DockerSandbox()()
}
