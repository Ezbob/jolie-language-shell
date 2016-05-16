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

		portExposed = 8000; // maybe implement some checks for in-use

		requestSandbox@JolieDocker( {
			.filename = startRequest.evaluatorFile,
			.containerName = startRequest.containerName,
			.port = portExposed,
			.detach = true
		} )( startDockerResponse );

		trim@StringUtils(startDockerResponse.stderr)(stderr);
		trim@StringUtils(startDockerResponse.stdout)(stdout);
		
		if ( stderr != "" ) {
			startResponse.status = "FAILED";
			startResponse.error = startDockerResponse.stderr

		} else {		
			
			getSandboxIP@JolieDocker(startRequest.containerName)(addressResponse);
			
			DockerEvalOut.location = "socket://" + addressResponse.ipAddress + ":" + portExposed;
			DockerEvalOut.protocol = "sodep";

			global.containerName = startRequest.containerName;

			startResponse.status = "ACCEPTED";	
			startResponse.containerName = startRequest.containerName
		}
	} ]

	[ send( sendRequest )( sendResponse ) {
		install( sandbox_not_init => 
			println@Console( "Sandbox not initialized" )() 
		);

		valueToPrettyString@StringUtils(sendRequest)(pretty);
		println@Console( pretty )();
		println@Console( "-->" + global.containerName )();

		if ( global.containerName == sendRequest.containerName ) {

			nullProcess

		} else {
		 	throw( sandbox_not_init ) 
		}

	} ]

	[ stopSandbox( containerName )() {
		println@Console( "Container " + containerName + " halting..." )();
		haltSandbox@JolieDocker( containerName )( response );

		trim@StringUtils(response.stderr)(stderr);
		trim@StringUtils(response.stdout)(stdout);

		if ( stderr != "" ) {
			println@Console( "Halting error: " + response.stderr )();
			println@Console( "Container not halted." )()

		} else {
			println@Console( "Container " + containerName + " halted." )()	
		}
		
	} ] 
}