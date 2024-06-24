package org.example;

import org.apache.maven.shared.invoker.*;

import java.io.File;
import java.util.Collections;

public class InvokeMaven {

    private final String absPath;
    private final String pomPath;

    private final String mvnLogPath;
    private final String[] args = {
            "clean", // clean
            "compile -l mvn-compile.log -Drat.skip=true", // compile
            "test -l mvn-test.log -Drat.skip=true -Dmaven.test.failure.ignore", // test
            "dependency:copy-dependencies -l mvn-dependencies.log" // dependency
    };

    public InvokeMaven(String absPath) {
        this.absPath = absPath;
        this.pomPath = absPath + "pom.xml";
        this.mvnLogPath = absPath + "mvn-test.log";
    }

    public void run() throws MavenInvocationException {
        File mvnTestFile = new File(mvnLogPath);
        File mvnDependenciesFile = new File(absPath + "mvn-dependencies.log");
        File mvnCompileFile = new File(absPath + "mvn-compile.log");

        if(!mvnTestFile.exists() && !mvnTestFile.isDirectory()
                && !mvnDependenciesFile.exists() && !mvnDependenciesFile.isDirectory()
                && !mvnCompileFile.exists() && !mvnCompileFile.isDirectory()) {
            invokeMaven();
        }
    }
    public void invokeMaven() throws MavenInvocationException {
        for (String arg : this.args){
            InvocationRequest request = new DefaultInvocationRequest();
            request.setPomFile(new File(this.pomPath));
            request.setGoals(Collections.singletonList(arg));

            Invoker invoker = new DefaultInvoker();
            invoker.setLogger(new SystemOutLogger());
            invoker.setMavenHome(new File(System.getenv().get("MAVEN_HOME")));
            invoker.execute(request);
        }
    }
}
