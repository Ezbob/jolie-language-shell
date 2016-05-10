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
	startSandBoxRequest.evaluatorFile = "~/Documents/jolieFun/server.ol";
  	requestSandbox@DockerEvalOut( startSandBoxRequest )( sandBoxLocation );
  	valueToPrettyString@StringUtils( sandBoxLocation )( fun );
  	println@Console( fun )()
}