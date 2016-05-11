
interface PathInterface {
  RequestResponse: 
	getAbsolutePath(string)(string),
	getAbsoluteParentPath(string)(string)
}


outputPort Path {
Interfaces: PathInterface
}

embedded {
Java:
	"joliexx.io.Path" in Path
}
