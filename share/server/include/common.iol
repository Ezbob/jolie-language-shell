
type LoadRequest:void {
  .program:string
  .short:bool
}

interface ExportedOperationsIFace {
	RequestResponse: 
		eval(LoadRequest)(undefined)
}