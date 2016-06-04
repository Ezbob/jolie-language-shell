
type sandboxStartRequest:void {
	.filename:string
	.containerName:string
	.port:int
	.detach:bool
}

type sandboxCommandResponse:void {
	.stderr?:string
	.stdout?:string
	.exitCode:int
}

type ipResponse:void {
	.ipAddress?:string
	.error?:string
}

interface JolieDockerInterface {
	RequestResponse: 
  		requestSandbox( sandboxStartRequest )( sandboxCommandResponse ),
  		haltSandbox( string )( sandboxCommandResponse ),
  		getSandboxIP( string )( ipResponse )
}


outputPort JolieDocker {
	Interfaces: JolieDockerInterface
}

embedded {
Java:
	"joliexx.docker.service.JolieDocker" in JolieDocker
}
