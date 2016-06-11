include "../javaServices/interfaces/jolie_docker.iol"
include "../javaServices/interfaces/file_extras.iol"
include "file.iol"
include "string_utils.iol"
include "console.iol"
include "docker_jolie.iol"
include "runtime.iol"

execution { sequential }

inputPort DockerEvalIn {
	Location: "socket://localhost:9000"
	Protocol: sodep
	Interfaces: ContainerConfigIFace
}

define copyToTmp
{
	tmpFileLink = global.tmp + "/" + startRequest.containerName + ".jap";

	copy@FileExtras( {
		.sourceFile = startRequest.evaluatorJap,
		.destinationFile = tmpFileLink
	} )( japsFile )
}

init {
	global.tmp = "tmp";

	exists@File( global.tmp )( tmpExists );

	if ( tmpExists ) {
		deleteDir@File( global.tmp )()
	};

	mkdir@File( global.tmp )( exists )	
}

main {
	[ requestSandbox( startRequest )( startResponse ) {

		copyToTmp;

		println@Console( "Received request for container: " + startRequest.containerName )();
		
		requestSandbox@JolieDocker( {
			.filename = tmpFileLink,
			.containerName = startRequest.containerName,
			.port = startRequest.exposedPort,
			.detach = true
		} )( startDockerResponse );

		startResponse.containerName = startRequest.containerName;

		if ( is_defined( startDockerResponse.stderr ) ) {

			startResponse = "FAILED";
			startResponse.error = startDockerResponse.stderr
		} else {
			
			println@Console( "Request granted for container: " + startRequest.containerName )();
			print@Console( "Testing connection for container..." )();

			waitForSignal@JolieDocker( {
				.containerName = startRequest.containerName
				})(
				signalResponse
			);

			if ( signalResponse.isAlive ) {
				println@Console( "done." )();
				startResponse = "ACCEPTED"	
			} else {
				haltSandbox@JolieDocker( startRequest.containerName )( haltResponse );
				startResponse = "FAILED";

				if ( is_defined( haltResponse.stderr ) ) {
					startResponse.error = haltResponse.stderr	
				}
			}
		}
	} ] 

	[ getLocation( containerName )( locationResponse ) {

		println@Console( "Location request for container " + containerName )();
		getSandboxIP@JolieDocker( containerName )( addressResponse );
		
		locationResponse = addressResponse.ipAddress;

		if ( is_defined( addressResponse.ports ) ) {
			locationResponse.ports = addressResponse.ports
		};

		println@Console( "Location sent for container " +  containerName + "." )()

	} ]

	[ getLastLogEntry( containerName )( outputResponse ) {

		logRequest = containerName;
		logRequest.tail = 1;

		getLog@JolieDocker( logRequest )( logResponse );
		if ( is_defined( logResponse.log ) ) {
			outputResponse = logResponse.log
		} else if ( is_defined( logResponse.error ) ) {
			outputResponse = logResponse.error
		} else {
			outputResponse = ""
		}
	}]

	[ getWholeLog( containerName )( outputResponse ) {

		getLog@JolieDocker( containerName )( logResponse );
		if ( is_defined( logResponse.log ) ) {
			outputResponse = logResponse.log
		} else if ( is_defined( logResponse.error ) ) {
			outputResponse = logResponse.error
		} else {
			outputResponse = ""
		}
	}]
	
	[ stopSandbox( containerName )() {

		println@Console( "Container " + containerName + " halting..." )();
		haltSandbox@JolieDocker( containerName )( response );

		if ( is_defined( response.stderr ) ) {
			println@Console( "Halting error: " + response.stderr )();
			println@Console( "Container not halted." )()

		} else {
			println@Console( "Container " + containerName + " halted." )()	
		}
		
	} ]

	[ shutdown()() {
		print@Console( "Shutting down..." )();
		deleteDir@File( global.tmp )( deleted );
		println@Console( "done." )();
		halt@Runtime({ .status = 0 })()
	} ] 
}