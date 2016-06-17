include "../dockerService/docker_jolie.iol"
include "../javaServices/interfaces/file_extras.iol"
include "../frontend/frontend_service.iol"
include "../share/shared.iol"
include "console.iol"
include "time.iol"
include "file.iol"
include "string_utils.iol"
include "eval_test.iol"

execution { 
	concurrent 
}

inputPort WebIn {
    Location: "socket://localhost:9002"
    Protocol: http { 
        .format = "html";
        .contentType -> mime;
        .default = "editor";
        .statusCode -> statusCode;
        .cacheControl << { .maxAge = 60 }
    }
    Interfaces: WebIface
}

outputPort ContainedService {
    Interfaces: ExportedOperationsIFace
    Protocol: sodep
}

outputPort DockerSandbox {
    Location: "socket://localhost:9000"
    Protocol: sodep
    Interfaces: ContainerConfigIFace
}

constants {
    WWWDirectory = "../frontend/public/"
}


init
{
    println@Console( "Starting..." )();
    global.containerName = "test1";
    japPath = "../share/server/server.jap";
    
    toAbsolutePath@FileExtras( japPath )( japAbsPath );
    requestSandbox@DockerSandbox( {
      .containerName = global.containerName,
      .evaluatorJap = japAbsPath,
      .exposedPort = 8005
    } )( sandboxResponse );

    getLocation@DockerSandbox( global.containerName )( location );

    ContainedService.location = "socket://" + location + ":" + location.ports[0];
    println@Console( ContainedService.location )();
    
  //  start@FrontendOut()();
    println@Console( "Started." )()
}

define defaultPage {
    // Default page: index.html
    shouldAddIndex = false;
    if ( op.result[0] == "" ) {
        shouldAddIndex = true
    } else {
        e = op.result[0];
        e.suffix = "/";
        endsWith@StringUtils( e )( shouldAddIndex )
    };
    if ( shouldAddIndex ) {
        op.result[0] = "index.html"
    }
}

main
{
 	[ runCode( request )( token ) {
        println@Console( "hello from runCode!" )();
        valueToPrettyString@StringUtils( request )( pretty );
        println@Console( "We got this: " + pretty )();
    	load@ContainedService( request )( token )
  	} ]

    [ editor(request)(response) {
        println@Console( "hello from editor!" )();
        scope( scp ) {
            install( FileNotFound => 
                println@Console( "[FILE NOT FOUND: " + filename + " ]" )(); 
                statusCode = 404 
            );

            if ( is_defined( request.data._escaped_fragment_ ) ) {
                request.operation = request.data._escaped_fragment_
            };

            op = request.operation;
            op.regex = "\\?";
            split@StringUtils( op )( op );

            defaultPage;

            filename = WWWDirectory + op.result[0];
            
            toAbsolutePath@FileExtras( filename )( filename );

            readFile@File({ .filename = filename } )( response );

            getMimeType@FileExtras( filename )( mime );
            println@Console( "[SERVED: " + op.result[0] + ", CONTENT-TYPE: " + mime + " ]" )()
        }
    } ]

	[ stop()(response) {
		stopSandbox@DockerSandbox( global.containerName )();
    	shutdown@DockerSandbox()();
    //    stop@FrontendOut()();
    	response = "STOPPED"
	}]
}
