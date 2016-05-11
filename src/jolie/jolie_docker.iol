
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

interface JolieDockerInterface {
	RequestResponse: 
  		requestSandBox( sandboxStartRequest )( sandboxStartResponse )
}


outputPort JolieDocker {
	Interfaces: JolieDockerInterface
}

embedded {
Java:
	"joliexx.docker.service.JolieDocker" in JolieDocker
}
