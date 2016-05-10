
type sandBoxLocation:void {
    .status:string
    .url:string
    .port:long
}

type startSandBoxRequest:void {
    .evaluatorFile:string
}

type evalRequest:string {
    .size:long
}

type evalResponse:string {
	.size:long
	.status:string
}

interface DockerEvaluatorIFace {
    RequestResponse: 
        requestSandbox(startSandBoxRequest)(sandBoxLocation),
        evaluate(evalRequest)(evalResponse)
    OneWay:
        stopSandbox(void)
}
