
type sandboxResponse:void {
    .status:string
    .containerName?:string
    .error?:string
}

type sandboxRequest:void {
    .evaluatorFile:string
    .containerName:string 
}

type sendResponse:void {
    .stdout?:string
    .stderr?:string
}

type sendRequest:void {
    .containerName:string
    .language:string
    .code:string
}

interface ContainerConfigIFace {
    RequestResponse: 
        requestSandbox( sandboxRequest )( sandboxResponse ),
        send('sendRequest )( sendResponse ),
        stopSandbox( string )( void )
}
