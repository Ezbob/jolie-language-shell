include "dockerEvaluatorIFace.iol"
include "file.iol"
include "string_utils.iol"
include "json_utils.iol"
include "exec.iol"
include "console.iol"
include "path.iol"
include "jolie_docker.iol"

execution { concurrent }

inputPort DockerEvalIn {
    Location: "socket://localhost:9000"
    Protocol: sodep
    Interfaces: DockerEvaluatorIFace
}

define getContainerIP
{
  	docker = "docker"; // jolie doesn't like docker's json for some reason
  	with( docker ) {
  	  .args[0] = "inspect";
  	  .args[1] = "--format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'";
  	  .args[2] = startRequest.containerName;
  	  .stdOutConsoleEnable = false
  	};
  	exec@Exec( docker )( dockerOut );
  	
  	trim@StringUtils( string( dockerOut ) )( dockerInstanceIP );
  	undef( dockerOut );
  	undef( docker )
}

main {
	[ requestSandbox( startRequest )( response ) {

		portExposed = 8000; // maybe implement some checks for 

		requestSandBox@JolieDocker( {
			.filename = startRequest.evaluatorFile,
			.containerName = startRequest.containerName,
			.port = portExposed,
			.detach = true
		} )( startDockerResponse );
		
		if ( is_defined( startDockerResponse.stderr ) ) {
			response.status = "FAILED";
			response.error = startDockerResponse.stderr
		} else {		
			getContainerIP;
			response.status = "ACCEPTED";
			response.ip = dockerInstanceIP;
			response.port = portExposed	
		}
	} ]

	[ evaluate( evalRequest )( evalResponse ) {
		nullProcess
	} ] 

	[ stopSandbox()() {
		nullProcess
	} ] 
}