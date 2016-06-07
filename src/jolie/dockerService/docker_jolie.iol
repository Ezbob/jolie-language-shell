
type sandboxResponse:string {
    .containerName:string
    .location?:string
    .protocol?:string
    .error?:string
}

type sandboxRequest:void {
    .evaluatorJap:string
    .containerName:string 
}

type locationResponse:string {
    .error?:string
}

interface ContainerConfigIFace {
    RequestResponse: 
        requestSandbox( sandboxRequest )( sandboxResponse ),
        getLocation( string )( string ),
        stopSandbox( string )( void ),
        getLastOutput( string )( string ),
        getAllOutput( string )( string )
}
