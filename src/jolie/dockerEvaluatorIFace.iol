
type sandboxResponse:string {
    .containerName:string
    .error?:string
}

type sandboxRequest:void {
    .evaluatorFile:string
    .containerName:string 
}

type evalRequest:string {
    .language:string
}

type evalResponse:string {
    .error?:string
}

interface ContainerConfigIFace {
    RequestResponse: 
        requestSandbox( sandboxRequest )( sandboxResponse ),
        evaluate( evalRequest )( evalResponse ),
        stopSandbox( string )( void )
}
