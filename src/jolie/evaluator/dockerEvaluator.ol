include "../jolieExtensions/interfaces/jolie_docker.iol"
include "../jolieExtensions/interfaces/file_extras.iol"
include "../jolieExtensions/interfaces/path.iol"
include "file.iol"
include "string_utils.iol"
include "console.iol"
include "dockerEvaluatorIFace.iol"
include "jar:file://" + japsFile + "!/common.iol"


execution { sequential }

inputPort DockerEvalIn {
	Location: "socket://localhost:9000"
	Protocol: sodep
	Interfaces: ContainerConfigIFace
}


define copyToTmp
{
	exists@File( "tmp" )( tmpExists );

	if ( tmpExists ) {
		deleteDir@File( "tmp" )(  )
	};

	mkdir@File( "tmp" )( exists );
	tmpFileLink = "tmp/" + startRequest.containerName + ".jap";

	println@Console( startRequest.evaluatorJap )();

	copyFile@FileExtras( {
		.sourceFile = startRequest.evaluatorJap,
		.destinationFile = tmpFileLink
	} )()
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
		nullProcess
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