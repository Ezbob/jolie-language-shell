include "common.iol"

outputPort FunOut {
	//Location: "socket://172.17.0.2:8000"
	//Protocol: sodep
	Interfaces: ExportedOperationsIFace
}

main
{
	FunOut.location = "socket://172.17.0.2:8000";
	FunOut.protocol = "sodep";
 	hello@FunOut()()
}