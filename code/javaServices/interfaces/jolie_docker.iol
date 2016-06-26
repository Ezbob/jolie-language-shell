
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

type signalWaitRequest:void {
	.containerName:string
	.printInfo?:bool
	.attempts?:int 
	.signalMessage?:string
}

type signalWaitResponse:void {
	.isAlive:bool
}

interface JolieDockerInterface {
	RequestResponse: 
  		requestSandbox( sandboxStartRequest )( sandboxCommandResponse ),
  		haltSandbox( string )( sandboxCommandResponse ),
  		getSandboxIP( string )( ipResponse ),
  		waitForSignal( signalWaitRequest )( signalWaitResponse ),
  		getLog( logRequest )( logResponse ),
  		attach( string )( void )
}


outputPort JolieDocker {
	Interfaces: JolieDockerInterface
}

embedded {
	Java: "joliexx.docker.service.JolieDocker" in JolieDocker
}
