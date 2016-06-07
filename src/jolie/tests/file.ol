include "../javaServices/interfaces/file_extras.iol"

main 
{
	copyFile@FileExtras({
		.sourceFile = "server.jap",
		.destinationFile = "server2.jap"
	})()
}
