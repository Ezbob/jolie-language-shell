
type sandboxLocation:void {
    .status:string
    .ip?:string
    .port?:int
    .error?:string
}

type startRequest:void {
    .evaluatorFile:string
    .containerName:string 
}

type evalRequest:string {
    .size:long
}

type evalResponse:string {
	.size:long
	.status:string
}

interface DockerEvaluatorIFace {
    RequestResponse: 
        requestSandbox( startRequest)( sandboxLocation ),
        evaluate( evalRequest )( evalResponse ),
        stopSandbox( void )( void )
}
