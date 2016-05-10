include "dockerEvaluatorIFace.iol"
include "file.iol"
include "string_utils.iol"
include "json_utils.iol"
include "exec.iol"
include "console.iol"

execution { concurrent }

inputPort DockerEvalIn {
    Location: "socket://localhost:9000"
    Protocol: sodep
    Interfaces: DockerEvaluatorIFace
}

init {
	deleteDir@File( ".tmp" )();
	mkdir@File( ".tmp" )()
}

define dockerExecution
{
	getServiceDirectory@File( void )( serviceDir );
	docker = "../scripts/run.sh";
	with ( docker ) {
		.args[0] = "8000";
		.args[1] = tmpFileName;
		.args[2] = "true";
		.waitFor = 2000;
		.stdOutConsoleEnable = false
	};
	exec@Exec( docker )( dockerOut );
	dockerInstanceId = string( dockerOut );
	undef( docker )
}

define getContainerIP
{
  	docker = "../scripts/getIp.sh"; // jolie doesn't like docker's json for some reason
  	with( docker ) {
  	  .args[0] = dockerInstanceId;
  	  .stdOutConsoleEnable = false
  	};
  	exec@Exec( docker )( dockerOut );
  	dockerInstanceIP = string( dockerOut );
  	undef ( dockerOut )
}

define copyToTemp
{

  	readFile@File({ .filename = startRequest.evaluatorFile })( copyContent );

	tmpFileName = ".tmp/" + randomName + ".ol";

	writeFile@File( { .filename = tmpFileName, .content = copyContent } )()
}

main {
	[ requestSandbox( startRequest )( response ) {
		
		getRandomUUID@StringUtils()( randomName );
		copyToTemp;
		dockerExecution;
		getContainerIP;

		println@Console( dockerInstanceIP )();
		
		response.status = "ACCEPTED";
		response.ip = dockerInstanceIP;
		response.port = 8000
	} ]

	[ evaluate( evalRequest )( evalResponse ) {
		nullProcess
	} ] 

	[ stopSandbox()() {
		nullProcess
	} ] 
}