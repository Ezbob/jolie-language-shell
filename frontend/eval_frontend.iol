include "protocols/http.iol"

type RunRequest:void {
	.program:string
	.short:bool
}

interface WebIface {
	RequestResponse:
	  runCode(RunRequest)(undefined),
	  editor(undefined)(undefined),
	  shutdown(void)(undefined)
}
