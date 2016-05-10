include "dockerEvaluatorIFace.iol"
include "file.iol"
include "string_utils.iol"
include "exec.iol"

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
	docker = "./scripts/run.sh";
	with( docker ){
		.args[0] = "8000";
		.args[1] = tmpFileName;
		.args[2] = "true";
		.stdOutConsoleEnable = false
	};
	exec@Exec( docker )( dockerResult );
	
	undef( docker );
	
	dockerInstanceId = string( dockerResult )
}

define inspectContainer
{
  	docker = "sudo";
  	with( docker ) {
  	  .args[0] = "docker";
  	  .args[1] = "inspect";
  	  .args[2] = dockerInstanceId;
  	  .stdOutConsoleEnable = false
  	};
  	exec@Exec( docker )( dockerResult );

  	valueToPrettyString@StringUtils( dockerResult )( pretty );
  	
  	println@Console( pretty )()
}

define copyToTemp
{
  	readFile@File({ .filename = startRequest.evaluatorFile })(copyContent);
		
	tmpFileName = ".tmp/" + randomName + ".ol";

	with ( newFile ) {
		.content = copyContent;
		.filename = tmpFileName
	};

	writeFile@File( newFile )()	
}

main {
	[ requestSandbox( startRequest )( response ) {
		
		getRandomUUID@StringUtils()( randomName );

		copyToTemp;
		dockerExecution;
		inspectContainer;
		
		response.status = "TEST";
		response.url = "";
		response.port = 8000
	} ] 

	[ evaluate( evalRequest )( evalResponse ) {
		nullProcess
	} ]

	[ stopSandBox() {
		nullProcess
	} ]
}