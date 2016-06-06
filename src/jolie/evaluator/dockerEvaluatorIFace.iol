
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

type bindingResponse:void {
    .location:string
    .protocol:string
}

interface ContainerConfigIFace {
    RequestResponse: 
        requestSandbox( sandboxRequest )( sandboxResponse ),
        getBinding( string )( bindingResponse ),
        stopSandbox( string )( void ),
        getOutput( string )( string )
}
