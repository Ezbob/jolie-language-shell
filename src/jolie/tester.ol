include "dockerEvaluatorIFace.iol"
include "console.iol"
include "string_utils.iol"

outputPort DockerEvalOut {
	Location: "socket://localhost:9000"
	Protocol: sodep
	Interfaces: DockerEvaluatorIFace
}

main
{
  	requestSandbox@DockerEvalOut( {
  		.containerName = "test1",
  		.evaluatorFile = "/home/ezbob/Documents/jolieFun/server.ol"
  	} )( sandBoxLocation );
  	valueToPrettyString@StringUtils( sandBoxLocation )( fun );
  	println@Console( fun )()
}