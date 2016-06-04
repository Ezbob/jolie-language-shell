
type sandboxResponse:string {
    .containerName:string
    .error?:string
}

type sandboxRequest:void {
    .evaluatorJap:string
    .containerName:string 
}

interface ContainerConfigIFace {
    RequestResponse: 
        requestSandbox( sandboxRequest )( sandboxResponse ),
        stopSandbox( string )( void )
}
