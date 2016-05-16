
type sandboxStartRequest:void {
	.filename:string
	.containerName:string
	.port:int
	.detach:bool
}

type sandboxStartResponse:void {
	.stderr?:string
	.stdout?:string
	.exitCode:int
}

type haltSandboxResponse:void {
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
  		requestSandbox( sandboxStartRequest )( sandboxStartResponse ),
  		haltSandbox( string )( haltSandboxResponse ),
  		getSandboxIP( string )( ipResponse )
}


outputPort JolieDocker {
	Interfaces: JolieDockerInterface
}

embedded {
Java:
	"joliexx.docker.service.JolieDocker" in JolieDocker
}
