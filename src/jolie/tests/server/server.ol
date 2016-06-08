include "console.iol"
include "common.iol"

execution { concurrent }

inputPort Printer {
	Location: "socket://localhost:8000/"
	Protocol: sodep
	Interfaces: ExportedOperationsIFace
}

init
{
  println@Console( "ALIVE" )()
}

main
{
	[ hello( void )() {
		println@Console( "hello" )()
	} ]
}