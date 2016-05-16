type evalRequest:string {
	.language:string
}

type evalResponse:void {
	.result?:string
	.error?:string
}


interface EvaluatorIFace { 
  RequestResponse: 
  	evalCode( evalRequest )( evalResponse )
}