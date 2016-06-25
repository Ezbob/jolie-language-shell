package joliexx.executor;

import jolie.runtime.FaultException;

import java.util.concurrent.*;

public class TimeOutExecutor extends Executor {

    private Long timeOutMillis = 2000L;

    public void setTimeOut( Long timeout ) {
        timeOutMillis = timeout;
    }

    public Long getTimeOut() {
        return timeOutMillis;
    }

    @Override
    public RunResults execute(Boolean printToConsole, String... args) throws FaultException {

        ExecutorService singleExecutor = Executors.newSingleThreadExecutor();
        RunResults results;

        Callable<RunResults> execTask = () -> {
            ProcessBuilder processBuilder = new ProcessBuilder();
            processBuilder.command(args);

            Process process = processBuilder.start();

            int exitCode = process.waitFor();

            return new RunResults( readStream( process.getInputStream(), false, printToConsole ),
                    readStream( process.getErrorStream(), true, printToConsole ), exitCode );
        };

        try {
            Future taskResult = singleExecutor.submit( execTask );

            results = (RunResults) taskResult.get( timeOutMillis, TimeUnit.MILLISECONDS );

        } catch ( TimeoutException te ) {
            return new RunResults( "", "Operation Timed out", 1 );

        } catch ( Exception e ) {
            throw new FaultException( e );
        }

        return results;
    }

    public RunResults execute( String program, Boolean printToConsole, String... args ) throws FaultException {
        return execute( printToConsole, prependArg(program, args) );
    }
}
