
# Usage
Package the agent jar file.
```
mvn clean package
```

Find the packaged jar file in target directory and add it to the java command line options.
For example.
```$xslt
mvn test -javaagent:javaagent-1.0-SNAPSHOT-jar-with-dependencies.jar
```
