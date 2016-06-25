package joliexx.io;

import jolie.runtime.FaultException;
import jolie.runtime.JavaService;
import jolie.runtime.Value;
import jolie.runtime.embedding.RequestResponse;
import jolie.runtime.typing.TypeCastingException;

import java.io.*;
import java.nio.file.*;

public class FileExtensions extends JavaService {

    private IoHelpers helpers = new IoHelpers();

    @RequestResponse
    public Value copy( Value request ) throws FaultException {
        Value result = Value.create();

        String src = request.getFirstChild("sourceFile").strValue();
        String dest = request.getFirstChild("destinationFile").strValue();

        Path srcPath, destPath;
        try {
            srcPath = Paths.get( src ).toAbsolutePath().normalize();
            destPath = Paths.get( dest ).toAbsolutePath().normalize();
        } catch ( InvalidPathException ipe ) {
            throw new FaultException( ipe );
        }

        try {
            Files.copy( srcPath, destPath, StandardCopyOption.REPLACE_EXISTING );
        } catch (IOException ioe) {
            throw new FaultException( ioe );
        }

        result.setValue( dest );

        return result;
    }

    @RequestResponse
    public Value toAbsolutePath( Value request ) throws FaultException
    {
        Value response = Value.create();
        String fileName = request.strValue();

        Path absolutePath = null;

        try {
            absolutePath = Paths.get( fileName ).toAbsolutePath().normalize();
        } catch ( InvalidPathException invalidPathException ) {
            throw new FaultException( invalidPathException );
        }

        response.setValue( absolutePath.toString() );

        return response;
    }

    @RequestResponse
    public Value getMimeType( Value request ) throws FaultException {
        Value response = Value.create();
        String filename;
        try {
            filename = request.strValueStrict();
        } catch ( TypeCastingException tce ) {
            throw new FaultException( tce );
        }
        String mime;

        try {
            mime = helpers.getMimeType( filename );
        } catch ( FileNotFoundException fnfe ) {
            throw new FaultException(fnfe);
        }

        response.setValue( mime );

        return response;
    }
}
