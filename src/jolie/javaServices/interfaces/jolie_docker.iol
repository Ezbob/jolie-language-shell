
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
	.ports*:string
	.error?:string
}

type availabilityRequest:void {
	.printInfo:bool
	.ip:string
	.port:int
	.attempts:int
}

type availabilityResponse:void {
	.isUp:bool
}

type logResponse:void {
	.log?:string
	.error?:string
}

type logRequest:string {
	.tail?:int
}

interface JolieDockerInterface {
	RequestResponse: 
  		requestSandbox( sandboxStartRequest )( sandboxCommandResponse ),
  		haltSandbox( string )( sandboxCommandResponse ),
  		getSandboxIP( string )( ipResponse ),
  		pingForAvailability( availabilityRequest )( availabilityResponse ),
  		getLog( logRequest )( logResponse )
}


outputPort JolieDocker {
	Interfaces: JolieDockerInterface
}

embedded {
	Java: "joliexx.docker.service.JolieDocker" in JolieDocker
}
