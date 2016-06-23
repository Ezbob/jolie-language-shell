include "../dockerService/docker_jolie.iol"
include "file_extras.iol"
include "../share/shared.iol"
include "console.iol"
include "time.iol"
include "file.iol"
include "exec.iol"
include "string_utils.iol"
include "eval_frontend.iol"

execution { 
	concurrent 
}

constants {
    WWW_DIR = "../frontend/public/",
    WWW_LOCATION = "socket://localhost:8888",
    EVAL_PORT = 8005,
}

inputPort WebIn {
    Location: WWW_LOCATION
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

init {
    println@Console( "Starting..." )();

    exec@Exec("/bin/bash" {
        .args[0] = "../share/server/createJap.sh",
        .waitFor = 1
    })();

    global.containerName = "evaluator2000";
    japPath = "../share/server/server.jap";
    
    toAbsolutePath@FileExtras( japPath )( japAbsPath );
    requestSandbox@DockerSandbox( {
      .containerName = global.containerName,
      .evaluatorJap = japAbsPath,
      .exposedPort = EVAL_PORT
    } )( sandboxResponse );

    getLocation@DockerSandbox( global.containerName )( location );

    ContainedService.location = "socket://" + location + ":" + location.ports[0];
    
    println@Console( "Started." )();

    println@Console( "Browse to " + WWW_LOCATION )()

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

define notFoundPage {
    response = "<!DOCTYPE HTML><html><head><title>404 Request</title></head><body><h2>Code 404: File not found</h2>"
    + "<p>We're sorry, but the page that you request isn't there</p> <br/> <p>:,(</p></body></html>"
}

define shutdownPage {
    response = "<!DOCTYPE HTML><html><head><title>Server shutdown</title></head><body><h2>Server shutdown</h2>" 
    + "<p> Server is now down. Thanks for trying out the interactive Jolie interpreter!</p>"
}

main {
 	[ runCode( request )( response ) {
        scope( scp2 )
        {
            install( TypeMismatch => 
                println@Console( "Invalid request for runCode" )(); 
                throw( TypeMismatch ) 
            );
            eval@ContainedService( request )( response )
        }
  	} ]

    [ editor( request )( response ) {
        scope( scp ) {
            install( FileNotFound => 
                println@Console( "[FILE NOT FOUND: " + filename + " ]" )(); 
                notFoundPage;
                statusCode = 404 
            );

            // java script stuff??
            if ( is_defined( request.data._escaped_fragment_ ) ) {
                request.operation = request.data._escaped_fragment_
            };

            op = request.operation;
            println@Console( request.operation )();
            op.regex = "\\?"; // look for http args
            split@StringUtils( op )( op );

            // setting up the default index.html page
            defaultPage;

            filename = WWW_DIR + op.result[0];
            
            toAbsolutePath@FileExtras( filename )( filename );

            install( PermissionDenied => 
                println@Console( "[PERMISSION DENIED FOR: " + filename + " ]" )(); 
                notFoundPage;
                statusCode = 403 
            );

            toAbsolutePath@FileExtras( WWW_DIR )( absPublic );
            contains@StringUtils( filename { .substring = absPublic } )( inPublicDir );

            if ( !inPublicDir ) {
                throw( PermissionDenied )
            };

            readFile@File( { .filename = filename } )( response );

            getMimeType@FileExtras( filename )( mime );
            println@Console( "[SERVED: " + op.result[0] + ", CONTENT-TYPE: " + mime + " ]" )()
        }
    } ]

    [ shutdown()( response ) {
        print@Console( "Received shutdown request.\n Shutting down..." )();
        stopSandbox@DockerSandbox( global.containerName )();
        shutdown@DockerSandbox()();
        shutdownPage
    }] { println@Console( "done." )(); exit }
}
