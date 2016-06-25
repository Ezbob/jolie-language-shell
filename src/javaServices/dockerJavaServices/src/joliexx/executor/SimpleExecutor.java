package joliexx.executor;

import jolie.runtime.FaultException;
import java.io.IOException;

public class SimpleExecutor extends Executor {

    @Override
    public RunResults execute(Boolean printToConsole, String... args) throws FaultException {
        try {
            Process process = new ProcessBuilder( args ).start();

            try {
                return new RunResults( readStream(process.getInputStream(), false, printToConsole ),
                        readStream( process.getErrorStream(), true, printToConsole), process.waitFor() );

            } catch ( InterruptedException interruptedException ) {
                throw new FaultException(interruptedException);
            }
        } catch (IOException ioException) {
            throw new FaultException(ioException);
        }
    }

    public RunResults execute(String program, Boolean printToConsole, String... args) throws FaultException {
        return execute( printToConsole, prependArg(program, args) );
    }
}
