
type startServerRequest:void {
  	.publicDirectory:string
  	.url:string
  	.port:int
  	.resourceLocation?:string
  	.indexName?:string
}	

interface SimpleSparkServerInterface {
  RequestResponse: 
  	startServer(startServerRequest)(string),
  	stopServer(void)(string)
}

outputPort SimpleSparkServer { 
	Interfaces: SimpleSparkServerInterface
}

embedded {
	Java: "joliexx.webserver.SimpleSparkServer" in SimpleSparkServer
}
