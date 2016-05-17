include "dockerEvaluatorIFace.iol"
include "file.iol"
include "string_utils.iol"
include "json_utils.iol"
include "console.iol"
include "path.iol"
include "jolie_docker.iol"
include "containedServer/evaluator.iol"

execution { sequential }

inputPort DockerEvalIn {
	Location: "socket://localhost:9000"
	Protocol: sodep
	Interfaces: ContainerConfigIFace
}

outputPort DockerEvalOut {
	Interfaces: EvaluatorIFace 
}


define copyToTmp
{
	exists@File( ".tmp" )( tmpExists );

	if ( tmpExists ) {
		deleteDir@File( ".tmp" )(  )
	};

	mkdir@File( ".tmp" )( exists );
	getRandomUUID@StringUtils()( name );

	tmpFileLink = ".tmp/" + name + ".ol";
	readFile@File( { .filename = startRequest.evaluatorFile } )( contents );
	writeFile@File( { .filename = tmpFileLink, .content = contents } )()
}

main {
	[ requestSandbox( startRequest )( startResponse ) {

		copyToTmp;

		println@Console( "Received request for container: " + startRequest.containerName  )();
		portExposed = 8000; // maybe implement some checks for in-use

		requestSandbox@JolieDocker( {
			.filename = tmpFileLink,
			.containerName = startRequest.containerName,
			.port = portExposed,
			.detach = true
		} )( startDockerResponse );

		valueToPrettyString@StringUtils(startDockerResponse)(pretty);
		println@Console(  pretty )();

		startResponse.containerName = startRequest.containerName;

		if ( is_defined( startDockerResponse.stderr ) ) {
			startResponse = "FAILED";
			startResponse.error = startDockerResponse.stderr
		} else {
			getSandboxIP@JolieDocker( startRequest.containerName )( addressResponse );

			DockerEvalOut.location = "socket://" + addressResponse.ipAddress + ":" + portExposed;
			DockerEvalOut.protocol = "sodep";

			println@Console( "Request granted for container: " + startRequest.containerName )();		
			startResponse = "ACCEPTED"
		}
	} ]

	[ evaluate( evaluateRequest )( evaluateResponse ) {

		evalCode@DockerEvalOut( evaluateRequest )( response );
		if ( is_defined( response.result ) ) {
			evaluateResponse = response.result
		};

		if ( is_defined( response.error ) ) {
			evaluateResponse.error = response.error
		}
	} ]
	
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