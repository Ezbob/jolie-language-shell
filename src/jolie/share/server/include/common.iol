
type LoadRequest:void {
  .program:string
  .short:bool
}

interface ExportedOperationsIFace {
	RequestResponse: 
		load(LoadRequest)(any),
  		unload(any)(void)
}