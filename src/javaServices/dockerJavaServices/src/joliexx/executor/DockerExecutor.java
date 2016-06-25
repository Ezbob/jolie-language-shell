package joliexx.executor;

import jolie.runtime.FaultException;
import java.io.IOException;

/**
 * Executing docker commands as command line interface
 * Currently only on unix machines with user in docker group
 */
public class DockerExecutor extends Executor {

    private static final String DOCKER_INVOCATION = "docker";

    @Override
    public RunResults execute(Boolean printToConsole, String... args) throws FaultException {

        try {
            Process process = new ProcessBuilder(
                    prependArg( DOCKER_INVOCATION, args )
            ).start();

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
}
