include "../jolieExtensions/interfaces/jolie_docker.iol"
include "../jolieExtensions/interfaces/file_extras.iol"
include "../jolieExtensions/interfaces/path.iol"
include "file.iol"
include "string_utils.iol"
include "console.iol"
include "dockerEvaluatorIFace.iol"


execution { sequential }

inputPort DockerEvalIn {
	Location: "socket://localhost:9000"
	Protocol: sodep
	Interfaces: ContainerConfigIFace
}

outputPort DockerEvalOut { }


define copyToTmp
{
	exists@File( "tmp" )( tmpExists );

	if ( tmpExists ) {
		deleteDir@File( "tmp" )(  )
	};

	mkdir@File( "tmp" )( exists );
	tmpFileLink = "tmp/" + startRequest.containerName + ".jap";

	copyFile@FileExtras( {
		.sourceFile = startRequest.evaluatorJap,
		.destinationFile = tmpFileLink
	} )( japsFile )
}

main {
	[ requestSandbox( startRequest )( startResponse ) {

		copyToTmp;

		println@Console( "Received request for container: " + startRequest.containerName )();
		portExposed = 8000; // maybe implement some checks for in-use

		requestSandbox@JolieDocker( {
			.filename = tmpFileLink,
			.containerName = startRequest.containerName,
			.port = portExposed,
			.detach = true
		} )( startDockerResponse );

		valueToPrettyString@StringUtils( startDockerResponse )( pretty );
		println@Console( pretty )();

		startResponse.containerName = startRequest.containerName;

		if ( is_defined( startDockerResponse.stderr ) ) {
			startResponse = "FAILED";
			startResponse.error = startDockerResponse.stderr
		} else {
			
			println@Console( "Request granted for container: " + startRequest.containerName )();
			println@Console( "Testing connection for container..." )();

			getSandboxIP@JolieDocker( startRequest.containerName )( address );

			pingForAvailability@JolieDocker({
					.printInfo = true,
					.ip = address.ipAddress,
					.port = int( address.ports[0] ),
					.attempts = 10000
			})( availability );

			if ( availability.isUp ) {
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

	[ getBinding( containerName )( bindingResponse ) {

		getSandboxIP@JolieDocker( containerName )( addressResponse );
		
		location = "socket://" + addressResponse.ipAddress + ":" + addressResponse.ports[0];
		protocol = "sodep";

		with ( bindingResponse ) {
			.location = location;
			.protocol = protocol
		}

	} ]

	[ getLastOutput( containerName )( outputResponse ) {

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

	[ getAllOutput( containerName )( outputResponse ) {

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

		valueToPrettyString@StringUtils( response )( pretty );
		println@Console( pretty )();

		if ( is_defined( response.stderr ) ) {
			println@Console( "Halting error: " + response.stderr )();
			println@Console( "Container not halted." )()

		} else {
			println@Console( "Container " + containerName + " halted." )()	
		};
		deleteDir@File( ".tmp" )( deleted )
	} ] 
}