include "dockerEvaluatorIFace.iol"
include "file.iol"
include "string_utils.iol"
include "json_utils.iol"
include "console.iol"
include "path.iol"
include "jolie_docker.iol"
include "evaluator.iol"

execution { concurrent }

inputPort DockerEvalIn {
    Location: "socket://localhost:9000"
    Protocol: sodep
    Interfaces: ContainerConfigIFace
}

outputPort DockerEvalOut {
	Interfaces: EvaluatorIFace 
}

main {
	[ requestSandbox( startRequest )( startResponse ) {

		println@Console( "Received request for container: " + startRequest.containerName  )();
		portExposed = 8000; // maybe implement some checks for in-use

		requestSandbox@JolieDocker( {
			.filename = startRequest.evaluatorFile,
			.containerName = startRequest.containerName,
			.port = portExposed,
			.detach = true
		} )( startDockerResponse );

		valueToPrettyString@StringUtils(startDockerResponse)(pretty);
		println@Console(  pretty )();

		if ( is_defined( startDockerResponse.stderr ) ) {
			startResponse = "FAILED";
			startResponse.containerName = startRequest.containerName
		} else {
			getSandboxIP@JolieDocker( startRequest.containerName )( addressResponse );

			DockerEvalOut.location = "socket://" + addressResponse.ipAddress + ":" + portExposed;
			DockerEvalOut.protocol = "sodep";

			println@Console( "Request granted for container: " + startRequest.containerName )();		
			startResponse = "ACCEPTED";
			startResponse.containerName = startRequest.containerName
		}
	} ]

	[ send( sendRequest )( sendResponse ) {
		install( sandbox_not_init => 
			println@Console( "Sandbox not initialized" )() 
		);

		valueToPrettyString@StringUtils(sendRequest)(pretty);
		println@Console( pretty )()

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
		}
		
	} ] 
}