package joliexx.executor;

import com.sun.istack.internal.NotNull;
import jolie.runtime.FaultException;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;


public abstract class Executor {

    public final class RunResults {
        private final String stdout;
        private final String stderr;
        private final Integer exitCode;

        public RunResults(String stdout, String stderr, Integer exitCode) {
            this.stderr = stderr;
            this.stdout = stdout;
            this.exitCode = exitCode;
        }

        public Integer getExitCode() {
            return exitCode;
        }

        public String getStderr() {
            return stderr;
        }

        public String getStdout() {
            return stdout;
        }

        public Boolean hasStdout() {
            return !this.stdout.isEmpty();
        }

        public Boolean hasStderr() {
            return !this.stderr.isEmpty();
        }
    }

    String[] prependArg(String arg, String[] args) {
        String[] extendedArgs = new String[args.length + 1];

        System.arraycopy(args, 0, extendedArgs, 1, args.length);
        extendedArgs[0] = arg;

        return extendedArgs;
    }

    String readStream(@NotNull InputStream stream, Boolean isErrorStream, Boolean printToConsole) throws IOException {
        StringBuilder result = new StringBuilder();
        String line;

        BufferedReader reader = new BufferedReader( new InputStreamReader( stream ) );
        while ( ( line = reader.readLine() ) != null ) {
            result.append(line + System.lineSeparator());

            if ( printToConsole ) {
                if ( isErrorStream ) {
                    System.err.println( line );
                } else {
                    System.out.println( line );
                }
            }
        }
        return result.toString().trim();
    }

    abstract public RunResults execute(Boolean printToConsole, String... args) throws FaultException;
}
