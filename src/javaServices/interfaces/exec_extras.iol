

type timeOutExecRequest:string {
	.timeOut:long // in milisecs
    .args*:string
    .printOut?:bool // get output on screen
}

type timeOutExecResponse:void {
	.exitCode:int
	.stdout?:string
	.stderr?:string
}

interface ExecExtrasInterface {
  RequestResponse: 
     timeOutExec( timeOutExecRequest )( timeOutExecResponse ) 
}

outputPort ExecExtras {
	Interfaces: ExecExtrasInterface
}

embedded {
	Java: "joliexx.exec.ExecExtras" in ExecExtras
}
