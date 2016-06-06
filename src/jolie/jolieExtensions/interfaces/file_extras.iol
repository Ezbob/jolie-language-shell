
type copyRequest:void {
  .sourceFile:string
  .destinationFile:string
}

interface FileExtensionsInterface {
  RequestResponse: 
	copy( copyRequest )( string ),
	toAbsolutePath(string)(string)
}


outputPort FileExtras {
Interfaces: FileExtensionsInterface
}

embedded {
Java:
	"joliexx.io.FileExtensions" in FileExtras
}
