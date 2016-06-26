
type sandboxResponse:string {
    .containerName:string
    .location?:string
    .protocol?:string
    .error?:string
}

type sandboxRequest:void {
    .evaluatorJap:string
    .containerName:string
    .exposedPort?:int 
}

type locationResponse:string {
    .ports*:string
    .error?:string
}

interface ContainerConfigIFace {
    RequestResponse: 
        requestSandbox( sandboxRequest )( sandboxResponse ),
        getLocation( string )( locationResponse ),
        stopSandbox( string )( void ),
        getLastLogEntry( string )( string ),
        getWholeLog( string )( string ),
        shutdown( void )( void )
}
