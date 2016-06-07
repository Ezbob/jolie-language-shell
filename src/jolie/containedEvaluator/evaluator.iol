type runRequest:string {
	.language:string
}

type runResponse:void {
	.result?:string
	.error?:string
}

interface EvaluatorIFace { 
  RequestResponse: 
  	evalCode( runRequest )( runResponse )
}