
type copyFileRequest:void {
  .sourceFile:string
  .destinationFile:string
}

interface FileExtensionsInterface {
  RequestResponse: 
	copyFile( copyFileRequest )( string )
}


outputPort FileExtras {
Interfaces: FileExtensionsInterface
}

embedded {
Java:
	"joliexx.file.FileExtensions" in FileExtras
}
