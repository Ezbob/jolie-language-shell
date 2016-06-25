package joliexx.docker.service;

import jolie.runtime.*;
import jolie.runtime.embedding.RequestResponse;
import jolie.runtime.typing.TypeCastingException;
import joliexx.executor.DockerExecutor;
import java.nio.file.Paths;

public class JolieDocker extends JavaService {

    /*
     * if tail is zero then the whole log is read
     */
    private synchronized String[] getLog( String containerName, boolean appendStderr, int tail ) throws FaultException {

        DockerExecutor.RunResults log;
        DockerExecutor docker = new DockerExecutor();

        if ( tail == 0 ) {
            log = docker.execute( false, "logs", containerName );
        } else {
            log = docker.execute( false, "logs", "--tail", Integer.toString( tail ), containerName );
        }

        StringBuilder out = new StringBuilder();

        if ( !log.getStdout().trim().isEmpty() ) {
            out.append(log.getStdout());
        }

        if ( appendStderr && !log.getStderr().trim().isEmpty() ) {
            out.append(log.getStderr());
        }

        return out.toString().split( System.lineSeparator() );
    }

    /*
     * get the whole log without errors from the execution
     */
    private String[] getLog( String containerName ) throws FaultException {
        return getLog( containerName, false, 0 );
    }


    @RequestResponse
    public Value requestSandbox( Value request ) throws FaultException {
        Value response = Value.create();
        String fileName = request.getFirstChild( "filename" ).strValue();
        String containerName = request.getFirstChild( "containerName" ).strValue();
        Integer port = request.getFirstChild( "port" ).intValue();
        Boolean detach = request.getFirstChild( "detach" ).boolValue();

        String mountPoint = Paths.get( fileName ).toAbsolutePath().normalize().getParent().toString();
        String nameOnly = Paths.get( fileName ).getFileName().toString();

        DockerExecutor docker = new DockerExecutor();
        String[] args;

        if ( detach ) {
            args = new String[] { "run", "-id", "--read-only", "--volume", mountPoint + ":/home/jolie",
                    "-m", "256m", "--cpu-shares", "256", "--cpuset-cpus", "0,1", "--expose", port.toString() , "--name", containerName,
                    "ezbob/jolie:latest", nameOnly };

        } else {
            args = new String[] {
                    "run", "-i", "--rm", "--read-only", "--volume", mountPoint + ":/home/jolie",
                    "-m", "256m", "--cpu-shares", "256", "--cpuset-cpus", "0,1", "--expose", port.toString() , "--name", containerName,
                    "ezbob/jolie:latest", nameOnly
            };
        }

        DockerExecutor.RunResults results = docker.execute(false, args);

        if ( !results.getStderr().isEmpty() ) {
            response.setFirstChild("stderr", results.getStderr());
        }

        if ( !results.getStdout().isEmpty() ) {
            response.setFirstChild("stdout", results.getStdout());
        }

        response.setFirstChild("exitCode", results.getExitCode());

        return response;
    }

    @RequestResponse
    public Value haltSandbox( Value request ) throws FaultException {
        Value response = Value.create();
        String containerName = request.strValue();
        DockerExecutor docker = new DockerExecutor();

        Integer exitCode = 0;
        StringBuilder stdout = new StringBuilder();
        StringBuilder stderr = new StringBuilder();
        DockerExecutor.RunResults results;

        results = docker.execute(false, "stop", containerName );

        stdout.append( results.getStdout().trim() );
        stderr.append( results.getStderr().trim() );

        exitCode = results.getExitCode();

        results = docker.execute(false, "rm", containerName );

        stdout.append( System.lineSeparator() );
        stdout.append( results.getStdout().trim() );

        stderr.append( System.lineSeparator() );
        stderr.append( results.getStderr().trim() );

        if ( exitCode == 0 && results.getExitCode() != 0 ) {
            exitCode = results.getExitCode();
        }

        if ( !stdout.toString().trim().isEmpty() ) {
            response.setFirstChild("stdout", stdout.toString());
        }

        if ( !stderr.toString().trim().isEmpty() ) {
            response.setFirstChild("stderr", stderr.toString());
        }
        response.setFirstChild("exitCode", exitCode);

        return response;
    }

    @RequestResponse
    public Value getSandboxIP( Value request ) throws FaultException {

        Value response = Value.create();
        String containerName = request.strValue();
        DockerExecutor docker = new DockerExecutor();

        DockerExecutor.RunResults results = docker.execute( false,
                "inspect",
                "--format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'",
                containerName
        );

        DockerExecutor.RunResults portResults = docker.execute(false,
                "inspect",
                "--format='{{range $p, $conf := .Config.ExposedPorts}} {{$p}} {{end}}'",
                containerName
        );

        String[] ports = portResults.getStdout().split("\n");
        String errors = results.getStderr() + "\n" + portResults.getStderr();

        if ( ports.length > 0 ) {
            for ( int i = 0; i < ports.length; ++i ) {
                ports[i] = ports[i].split("/")[0];
            }
            ValueVector vec = response.getChildren("ports");

            for ( int i = 0; i < ports.length; i++ ) {
                vec.add( Value.create( ports[i].trim() ) );
            }
        }

        if ( !results.getStdout().isEmpty() ) {
            response.setFirstChild( "ipAddress", results.getStdout() );
        }

        if ( !errors.isEmpty() ) {
            response.setFirstChild( "error", errors );
        }

        return response;
    }

    @RequestResponse
    public Value attach( Value req ) throws FaultException {

        String containerName;
        try {
            containerName = req.strValueStrict();
        } catch (TypeCastingException tpe) {
            throw new FaultException(tpe);
        }

        DockerExecutor docker = new DockerExecutor();

        docker.execute( true, "attach", containerName );

        return Value.create();
    }

    /*
     * Check the logs for the alive signal
     */
    @RequestResponse
    public Value waitForSignal( Value request ) throws FaultException {

        Value result = Value.create();

        String containerName;
        try {
            containerName = request.getFirstChild("containerName").strValueStrict();
        } catch ( TypeCastingException te) {
            throw new FaultException( new TypeCastingException("containerName required") );
        }
        Boolean printOut = request.getFirstChild("printInfo").boolValue();
        Integer tries = request.hasChildren( "attempts" ) ? request.getFirstChild( "attempts" ).intValue() : 1000;
        String signal = request.hasChildren( "signalMessage" ) ? request.getFirstChild( "signalMessage" ).strValue() : "ALIVE";

        int tried = 1;
        boolean isAlive = false;

        if ( printOut ) {
            System.out.println("Checking for ready signal...");
        }

        for (; tried < tries; ++tried ) {
            if ( printOut ) {
                System.out.println( "Attempt #" + tried );
            }

            String[] logLines = getLog( containerName, false, 0 );
            for ( String line : logLines ) {

                if ( line.trim().equals( signal ) ) {
                    if ( printOut ) {
                        System.out.println( "Signal found." );
                    }
                    isAlive = true;
                    break;
                }
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException ie) {
                    throw new FaultException( ie );
                }
            }
            if ( isAlive ) {
                break;
            }
        }

        if ( tried >= tries ) {
            if ( printOut ) {
                System.out.println("Number of attempts exceeded. Signal not found.");
            }
        }

        result.setFirstChild( "isAlive", isAlive );

        return result;
    }


    @RequestResponse
    public Value getLog( Value request ) throws FaultException {

        Value result = Value.create();

        DockerExecutor.RunResults log;
        DockerExecutor docker = new DockerExecutor();

        if ( request.hasChildren( "tail" ) ) {

            log = docker.execute( false,
                    "logs", "--tail=" + request.getFirstChild( "tail" ).intValue(), request.strValue()
            );

        } else {

            log = docker.execute( false,
                    "logs", request.strValue()
            );
        }

        if ( !log.getStdout().isEmpty() ) {
            result.setFirstChild("log", log.getStdout());
        }

        if ( !log.getStderr().isEmpty() ) {
            result.setFirstChild("error", log.getStderr());
        }

        return result;
    }

}
